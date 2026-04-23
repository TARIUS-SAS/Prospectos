import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
}

interface PlaceDetailsRequest {
  place_id: string
  prospect_id?: string
  usuario_id?: string
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("", {
      status: 200,
      headers: corsHeaders,
    })
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    const body: PlaceDetailsRequest = await req.json()

    if (!body.place_id) {
      return new Response(
        JSON.stringify({ error: "Se requiere place_id" }),
        { status: 400, headers: corsHeaders }
      )
    }

    const googleApiKey = Deno.env.get("GOOGLE_PLACES_API_KEY")
    if (!googleApiKey) {
      return new Response(
        JSON.stringify({ error: "Google Places API key no configurada" }),
        { status: 500, headers: corsHeaders }
      )
    }

    // Llamar a Google Places Details API
    const fieldsToRequest = [
      "formatted_address",
      "formatted_phone_number",
      "international_phone_number",
      "opening_hours",
      "website",
      "business_status",
      "rating",
      "review",
      "photos",
      "place_id",
      "name",
      "type",
      "geometry",
      "url",
    ].join(",")

    const googleUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${body.place_id}&key=${googleApiKey}&fields=${fieldsToRequest}&language=es`

    const googleResponse = await fetch(googleUrl)
    const googleData = await googleResponse.json()

    // Extraer costo de la respuesta
    let costUsd = 0
    if (googleData.price_level) {
      // Aproximar costo basado en price_level (no es exacto pero da una idea)
      const costMap: Record<number, number> = { 1: 0.01, 2: 0.02, 3: 0.03, 4: 0.04 }
      costUsd = costMap[googleData.price_level] || 0.017
    } else {
      costUsd = 0.017 // Costo base de Place Details
    }

    // Registrar costo en BD
    if (body.usuario_id) {
      const { error: logError } = await supabase
        .from("api_costs")
        .insert({
          usuario_id: body.usuario_id,
          tipo_api: "google_places",
          operation: "get_place_details",
          costo_usd: costUsd,
          place_id: body.place_id,
          business_name: googleData.result?.name,
          request_data: { place_id: body.place_id },
          response_code: googleResponse.status,
        })

      if (logError) {
        console.error("Error logging API cost:", logError)
      }
    }

    // Actualizar prospects con el costo si tenemos prospect_id
    if (body.prospect_id) {
      const { error: updateError } = await supabase
        .from("prospects")
        .update({
          google_places_id: body.place_id,
          google_places_cost: costUsd,
          google_places_updated_at: new Date().toISOString(),
        })
        .eq("id", body.prospect_id)

      if (updateError) {
        console.error("Error updating prospect:", updateError)
      }
    }

    // Si hay error en Google
    if (!googleData.result) {
      return new Response(
        JSON.stringify({
          error: googleData.error_message || "No se encontraron detalles",
          costo_usd: costUsd,
        }),
        { status: 400, headers: corsHeaders }
      )
    }

    const result = googleData.result

    return new Response(
      JSON.stringify({
        place_id: result.place_id,
        nombre: result.name,
        direccion: result.formatted_address,
        telefono: result.formatted_phone_number,
        telefono_internacional: result.international_phone_number,
        website: result.website,
        rating: result.rating,
        url_google: result.url,
        estado_negocio: result.business_status,
        horarios: result.opening_hours?.weekday_text || [],
        abierto_ahora: result.opening_hours?.open_now,
        fotos: (result.photos || []).map((p: any) => ({
          url: `https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${p.photo_reference}&key=${googleApiKey}`,
          atribucion: p.html_attributions?.[0],
        })),
        reviews: (result.reviews || []).slice(0, 5).map((r: any) => ({
          autor: r.author_name,
          rating: r.rating,
          fecha: r.relative_time_description,
          texto: r.text,
        })),
        tipos: result.types || [],
        costo_usd: costUsd,
        latitud: result.geometry?.location?.lat,
        longitud: result.geometry?.location?.lng,
      }),
      { status: 200, headers: corsHeaders }
    )
  } catch (error) {
    console.error("Error:", error)
    return new Response(
      JSON.stringify({ error: "Error al obtener detalles: " + String(error) }),
      { status: 500, headers: corsHeaders }
    )
  }
})
