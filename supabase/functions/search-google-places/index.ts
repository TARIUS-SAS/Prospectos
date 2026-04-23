import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
}

interface SearchRequest {
  query: string
  zona: string
  tipo_negocio?: string
  empleados_range?: string
  presencia_web?: string
  cantidad_resultados: number
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

    const body: SearchRequest = await req.json()

    // Validar campos requeridos
    if (!body.query && !body.zona && !body.tipo_negocio) {
      return new Response(
        JSON.stringify({ error: "Se requiere al menos un parámetro de búsqueda" }),
        { status: 400, headers: corsHeaders }
      )
    }

    const cantidadSolicitada = Math.min(body.cantidad_resultados || 20, 100)

    // Buscar en tabla prospects (BD local como fallback hasta integrar Google Places)
    let query = supabase
      .from("prospects")
      .select("*")
      .limit(cantidadSolicitada)

    if (body.zona) {
      query = query.eq("zona", body.zona)
    }
    if (body.tipo_negocio) {
      query = query.ilike("tipo_negocio", `%${body.tipo_negocio}%`)
    }
    if (body.query) {
      query = query.or(`nombre.ilike.%${body.query}%,tipo_negocio.ilike.%${body.query}%`)
    }

    const { data: prospects, error: dbError } = await query

    if (dbError) {
      console.error("Database error:", dbError)
      return new Response(
        JSON.stringify({ error: "Error en búsqueda: " + dbError.message }),
        { status: 500, headers: corsHeaders }
      )
    }

    const resultados = (prospects || []).slice(0, cantidadSolicitada)

    return new Response(
      JSON.stringify({
        búsqueda_id: "temp-" + Date.now(),
        resultados: resultados,
        total: resultados.length,
      }),
      { status: 200, headers: corsHeaders }
    )
  } catch (error) {
    console.error("Error:", error)
    return new Response(
      JSON.stringify({ error: "Error al procesar búsqueda: " + String(error) }),
      { status: 500, headers: corsHeaders }
    )
  }
})
