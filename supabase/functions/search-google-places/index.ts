import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") || "http://localhost:5173",
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

    // Aquí iría la llamada a Google Places API con su key de Supabase secret
    // Por ahora, retorna estructura de respuesta (será implementado en fase 2)
    const mockResultados: Prospect[] = [
      {
        nombre: `${body.query} ${Math.random()}`,
        dirección: `${body.zona}, Calle Principal`,
        teléfono: "0987654321",
        website: null,
        https: null,
        facebook_instagram: null,
        google_rating: 4.5,
        google_reviews_count: 150,
        latitude: -0.2298,
        longitude: -78.5249,
      }
    ]

    // Calcular costo real (obtenido de admin_settings)
    const { data: costSettings } = await supabase
      .from("admin_settings")
      .select("valor")
      .eq("clave", "costo_google_places_per_result")
      .single()

    const costoReal = (parseFloat(costSettings?.valor || "0.0034") * body.cantidad_resultados)

    return new Response(
      JSON.stringify({
        resultados: mockResultados,
        total: mockResultados.length,
        costo_real: costoReal,
      }),
      { status: 200, headers: corsHeaders }
    )
  } catch (error) {
    console.error("Error:", error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: corsHeaders }
    )
  }
})
