import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const allowedOrigin = Deno.env.get("ALLOWED_ORIGIN")
if (!allowedOrigin) {
  throw new Error("ALLOWED_ORIGIN environment variable is required")
}

const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigin,
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type",
}

interface SearchRequest {
  query: string
  zona: string
  tipo_negocio?: string
  nombre?: string
  empleados_range?: string
  presencia_web?: string
  cantidad_resultados: number
  latitude?: number
  longitude?: number
}

interface Prospect {
  nombre: string
  dirección: string
  teléfono?: string
  website?: string
  https?: boolean
  facebook_instagram?: string
  google_rating?: number
  google_reviews_count?: number
  latitude?: number
  longitude?: number
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: corsHeaders }
      )
    }

    const token = authHeader.replace("Bearer ", "")
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid token" }),
        { status: 401, headers: corsHeaders }
      )
    }

    const body: SearchRequest = await req.json()

    // Rate limit: verificar búsquedas realizadas hoy por usuario
    const today = new Date().toISOString().split('T')[0]
    const { data: searchesHoy, count: searchCount } = await supabase
      .from('searches')
      .select('id', { count: 'exact' })
      .eq('usuario_id', user.id)
      .gte('timestamp', `${today}T00:00:00`)

    // Obtener límite de usuario desde users_metadata
    const { data: userMeta } = await supabase
      .from('users_metadata')
      .select('búsquedas_max_por_día')
      .eq('id', user.id)
      .single()

    const maxBúsquedas = userMeta?.búsquedas_max_por_día || 20
    if ((searchCount || 0) >= maxBúsquedas) {
      return new Response(
        JSON.stringify({ error: `Límite diario de ${maxBúsquedas} búsquedas alcanzado` }),
        { status: 429, headers: corsHeaders }
      )
    }

    // Validar campos requeridos
    if (!body.query || !body.zona) {
      return new Response(
        JSON.stringify({ error: "query y zona son requeridos" }),
        { status: 400, headers: corsHeaders }
      )
    }

    if (body.cantidad_resultados < 1 || body.cantidad_resultados > 50) {
      return new Response(
        JSON.stringify({ error: "cantidad_resultados debe estar entre 1 y 50" }),
        { status: 400, headers: corsHeaders }
      )
    }

    // Obtener costo real (operacional) desde admin_settings
    // IMPORTANTE: Se calculará DESPUÉS de obtener resultados para cobrar por lo obtenido, no por lo pidió
    const { data: costSettings } = await supabase
      .from("admin_settings")
      .select("valor")
      .eq("clave", "costo_google_places_per_result")
      .single()

    const costoUnitarioReal = parseFloat(costSettings?.valor || "0.0034")

    // Obtener plan activo del usuario para costos de venta (búsqueda y empresa)
    const { data: userPlan } = await supabase
      .from('user_subscriptions')
      .select('billing_plans(costo_búsqueda_venta, costo_empresa_venta)')
      .eq('usuario_id', user.id)
      .eq('estado', 'activo')
      .maybeSingle()

    // Si no hay plan activo, obtener plan Starter desde BD (no hardcoded)
    let costoVentaBúsqueda: number
    let costoVentaEmpresa: number

    if (userPlan?.billing_plans) {
      // Usuario tiene plan activo, usar sus costos (incluso si son 0)
      costoVentaBúsqueda = userPlan.billing_plans.costo_búsqueda_venta
      costoVentaEmpresa = userPlan.billing_plans.costo_empresa_venta
    } else {
      // Sin plan activo, obtener plan Starter desde BD
      const { data: starterPlan } = await supabase
        .from('billing_plans')
        .select('costo_búsqueda_venta, costo_empresa_venta')
        .eq('nombre', 'Starter')
        .single()

      costoVentaBúsqueda = starterPlan?.costo_búsqueda_venta ?? 0.50
      costoVentaEmpresa = starterPlan?.costo_empresa_venta ?? 0.05
    }

    // Obtener costo real por empresa desde admin_settings
    const { data: costEmpresaSettings } = await supabase
      .from("admin_settings")
      .select("valor")
      .eq("clave", "costo_empresa_real")
      .single()

    const costoRealEmpresa = parseFloat(costEmpresaSettings?.valor || "0.0020")

    // PASO 1: Registrar búsqueda en DB con estado 'en_progreso' ANTES de llamar a Google Places
    // Los costos son estimados (cantidad_resultados_pedida); se recalculan en PASO 3 con cantidad real obtenida
    const estimadoCostoRealBúsqueda = costoUnitarioReal * body.cantidad_resultados
    const { data: newSearch, error: insertError } = await supabase
      .from('searches')
      .insert([
        {
          usuario_id: user.id,
          query: body.query,
          zona: body.zona,
          tipo_negocio: body.tipo_negocio || null,
          nombre: body.nombre || null,
          empleados_range: body.empleados_range || null,
          presencia_web: body.presencia_web || null,
          cantidad_resultados_pedida: body.cantidad_resultados,
          costo_búsqueda_real: estimadoCostoRealBúsqueda,
          costo_búsqueda_venta: costoVentaBúsqueda,
          costo_empresas_real: 0,
          costo_empresas_venta: 0,
          costo_total_real: estimadoCostoRealBúsqueda,
          costo_total_venta: costoVentaBúsqueda,
          estado: 'en_progreso',
        }
      ])
      .select('id')
      .single()

    if (insertError || !newSearch) {
      return new Response(
        JSON.stringify({ error: 'Error al registrar búsqueda', details: insertError?.message }),
        { status: 500, headers: corsHeaders }
      )
    }

    // PASO 2: Llamar a Google Places API (Text Search)
    const googleApiKey = Deno.env.get("GOOGLE_API_KEY")
    if (!googleApiKey) {
      return new Response(
        JSON.stringify({ error: "Google API key not configured" }),
        { status: 500, headers: corsHeaders }
      )
    }

    // Construir query para Google Places
    // Ej: "Restaurantes en Centro, Quito, Ecuador"
    const searchQuery = `${body.query} en ${body.zona}, Quito, Ecuador`
    const textSearchUrl = new URL("https://maps.googleapis.com/maps/api/place/textsearch/json")
    textSearchUrl.searchParams.append("query", searchQuery)
    textSearchUrl.searchParams.append("key", googleApiKey)
    textSearchUrl.searchParams.append("language", "es")

    let googleResults: any[] = []
    try {
      const textSearchResponse = await fetch(textSearchUrl.toString())
      const textSearchData = await textSearchResponse.json()

      if (textSearchData.results && textSearchData.results.length > 0) {
        googleResults = textSearchData.results.slice(0, body.cantidad_resultados)
      }
    } catch (error) {
      console.error("Error en Google Text Search:", error)
      // Continuar sin resultados en lugar de fallar
    }

    // PASO 2B: Obtener detalles de cada lugar (nombre, teléfono, website, rating)
    const resultados: Prospect[] = []

    for (const place of googleResults) {
      try {
        const placeDetailsUrl = new URL("https://maps.googleapis.com/maps/api/place/details/json")
        placeDetailsUrl.searchParams.append("place_id", place.place_id)
        placeDetailsUrl.searchParams.append("fields", "name,formatted_address,formatted_phone_number,website,rating,user_ratings_total,geometry,business_status")
        placeDetailsUrl.searchParams.append("key", googleApiKey)
        placeDetailsUrl.searchParams.append("language", "es")

        const detailsResponse = await fetch(placeDetailsUrl.toString())
        const detailsData = await detailsResponse.json()
        const details = detailsData.result

        if (details && details.business_status === "OPERATIONAL") {
          resultados.push({
            nombre: details.name || place.name,
            dirección: details.formatted_address || place.formatted_address,
            teléfono: details.formatted_phone_number || undefined,
            website: details.website || undefined,
            https: details.website ? !details.website.startsWith("http://") : undefined,
            facebook_instagram: undefined, // No disponible en Google Places API
            google_rating: details.rating || undefined,
            google_reviews_count: details.user_ratings_total || 0,
            latitude: details.geometry?.location?.lat,
            longitude: details.geometry?.location?.lng,
          })
        }
      } catch (error) {
        console.error("Error obteniendo detalles del lugar:", error)
        // Continuar con siguientes resultados
      }
    }

    // Si no hay resultados de Google Places, retornar array vacío
    const mockResultados: Prospect[] = resultados.length > 0 ? resultados : []

    // PASO 3: Actualizar búsqueda con resultados finales y costos REALES basados en cantidad obtenida
    const cantidadEmpresas = mockResultados.length
    // Recalcular costo de búsqueda basado en CANTIDAD OBTENIDA, no pedida
    const costoRealBúsquedaFinal = costoUnitarioReal * cantidadEmpresas
    const costoEmpresasReal = cantidadEmpresas * costoRealEmpresa
    const costoEmpresasVenta = cantidadEmpresas * costoVentaEmpresa
    const costoTotalReal = costoRealBúsquedaFinal + costoEmpresasReal
    const costoTotalVenta = costoVentaBúsqueda + costoEmpresasVenta

    const { error: updateError } = await supabase
      .from('searches')
      .update({
        cantidad_resultados_obtenida: cantidadEmpresas,
        costo_búsqueda_real: costoRealBúsquedaFinal,
        costo_empresas_real: costoEmpresasReal,
        costo_empresas_venta: costoEmpresasVenta,
        costo_total_real: costoTotalReal,
        costo_total_venta: costoTotalVenta,
        estado: 'exitosa',
      })
      .eq('id', newSearch.id)

    if (updateError) {
      console.error('Error al actualizar búsqueda:', updateError)
      return new Response(
        JSON.stringify({ error: 'Error al finalizar búsqueda', details: updateError?.message }),
        { status: 500, headers: corsHeaders }
      )
    }

    return new Response(
      JSON.stringify({
        búsqueda_id: newSearch.id,
        resultados: mockResultados,
        total: cantidadEmpresas,
        costo_búsqueda_real: costoRealBúsquedaFinal,
        costo_búsqueda_venta: costoVentaBúsqueda,
        costo_empresas_real: costoEmpresasReal,
        costo_empresas_venta: costoEmpresasVenta,
        costo_total_real: costoTotalReal,
        costo_total_venta: costoTotalVenta,
      }),
      { status: 200, headers: corsHeaders }
    )
  } catch (error) {
    console.error("Error:", error)
    return new Response(
      JSON.stringify({ error: "Error al procesar búsqueda" }),
      { status: 500, headers: corsHeaders }
    )
  }
})
