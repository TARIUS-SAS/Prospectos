import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") || "http://localhost:5173",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type",
}

interface ProspectData {
  nombre: string
  website?: string
  https?: boolean
  facebook_instagram?: string
  sri_activo?: boolean
  teléfono?: string
  zona?: string
}

interface ScoreResponse {
  score: number
  desglose: Record<string, number>
  es_caliente: boolean
}

const ZONAS_COMERCIALES = [
  "Centro",
  "Cumbayá",
  "La Carolina",
  "Quito Norte",
  "Quito Sur",
  "Mariscal",
  "Aeropuerto",
]

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const body: ProspectData = await req.json()

    if (!body.nombre) {
      return new Response(
        JSON.stringify({ error: "nombre es requerido" }),
        { status: 400, headers: corsHeaders }
      )
    }

    let score = 0
    const desglose: Record<string, number> = {}

    // Scoring logic (0-24)
    if (!body.website) {
      score += 10
      desglose.sin_website = 10
    } else if (body.website && !body.https) {
      score += 5
      desglose.website_sin_https = 5
    }

    if (body.facebook_instagram) {
      score += 2
      desglose.tiene_redes = 2
    }

    if (body.sri_activo) {
      score += 3
      desglose.sri_activo = 3
    }

    if (body.teléfono) {
      score += 2
      desglose.tiene_teléfono = 2
    }

    if (body.zona && ZONAS_COMERCIALES.includes(body.zona)) {
      score += 2
      desglose.zona_comercial = 2
    }

    const esCaliente = score >= 15

    return new Response(
      JSON.stringify({
        score,
        desglose,
        es_caliente: esCaliente,
      } as ScoreResponse),
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
