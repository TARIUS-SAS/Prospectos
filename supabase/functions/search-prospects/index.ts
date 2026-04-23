import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const supabaseUrl = Deno.env.get("SUPABASE_URL")
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")

const supabase = createClient(supabaseUrl!, supabaseKey!)

interface SearchFilters {
  zona?: string
  tipo_negocio?: string
  palabra_clave?: string
  empleados_range?: string
  presencia_web?: string
  sri_activo?: boolean
  cantidad_resultados?: number
}

interface Prospect {
  id: string
  nombre: string
  direccion: string
  telefono?: string
  website?: string
  email?: string
  zona?: string
  tipo_negocio?: string
  ruc?: string
  sri_activo?: boolean
  google_rating?: number
  google_reviews?: number
  empleados_estimado?: string
  presencia_web?: string
  has_facebook?: boolean
  has_instagram?: boolean
  score: number
  score_breakdown?: Record<string, number>
}

function calculateScore(prospect: any): { score: number; breakdown: Record<string, number> } {
  const breakdown: Record<string, number> = {}
  let score = 0

  if (prospect.sri_activo) {
    breakdown.sri_activo = 20
    score += 20
  }

  if (prospect.google_rating) {
    const ratingScore = Math.min((prospect.google_rating / 5) * 15, 15)
    breakdown.google_rating = Math.round(ratingScore)
    score += ratingScore
  }

  if (prospect.google_reviews && prospect.google_reviews > 10) {
    breakdown.google_reviews = 10
    score += 10
  }

  if (prospect.presencia_web === "website") {
    breakdown.website_https = 15
    score += 15
  } else if (prospect.presencia_web === "redes") {
    breakdown.social_media = 10
    score += 10
  } else if (!prospect.website && !prospect.has_facebook && !prospect.has_instagram) {
    breakdown.sin_website = 15
    score += 15
  }

  if (prospect.telefono) {
    breakdown.telefono = 10
    score += 10
  }

  if (prospect.email) {
    breakdown.email = 5
    score += 5
  }

  if (prospect.empleados_estimado) {
    if (["5-20", "20-50"].includes(prospect.empleados_estimado)) {
      breakdown.empleados = 10
      score += 10
    }
  }

  const zonas_comerciales = ["Centro", "Cumbayá", "La Carolina", "Quito Norte"]
  if (prospect.zona && zonas_comerciales.includes(prospect.zona)) {
    breakdown.zona_comercial = 5
    score += 5
  }

  return { score: Math.min(score, 100), breakdown }
}

function matchesFilters(prospect: any, filters: SearchFilters): boolean {
  if (filters.zona && prospect.zona !== filters.zona) return false
  if (filters.tipo_negocio && !prospect.tipo_negocio?.toLowerCase().includes(filters.tipo_negocio.toLowerCase())) return false
  if (filters.palabra_clave) {
    const keyword = filters.palabra_clave.toLowerCase()
    const matchesNombre = prospect.nombre?.toLowerCase().includes(keyword)
    const matchesTipo = prospect.tipo_negocio?.toLowerCase().includes(keyword)
    if (!matchesNombre && !matchesTipo) return false
  }
  if (filters.empleados_range && prospect.empleados_estimado !== filters.empleados_range) return false
  if (filters.sri_activo && !prospect.sri_activo) return false

  if (filters.presencia_web) {
    if (filters.presencia_web === "sin_web" && (prospect.website || prospect.has_facebook || prospect.has_instagram)) return false
    if (filters.presencia_web === "redes" && (!prospect.has_facebook && !prospect.has_instagram)) return false
    if (filters.presencia_web === "website" && (!prospect.website || prospect.presencia_web !== "website")) return false
  }

  return true
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === "OPTIONS") {
    return new Response("", {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
        "Access-Control-Max-Age": "86400",
      },
    })
  }

  try {
    const body = await req.json()
    const filters: SearchFilters = body

    let query = supabase.from("prospects").select("*")

    if (filters.zona) query = query.eq("zona", filters.zona)
    if (filters.sri_activo) query = query.eq("sri_activo", true)
    if (filters.tipo_negocio) query = query.ilike("tipo_negocio", `%${filters.tipo_negocio}%`)
    if (filters.empleados_range) query = query.eq("empleados_estimado", filters.empleados_range)

    const { data: prospects, error } = await query.limit(100)

    if (error) throw error

    const scored: Prospect[] = (prospects || [])
      .map((p: any) => {
        const { score, breakdown } = calculateScore(p)
        return { ...p, score, score_breakdown: breakdown }
      })
      .filter((p) => matchesFilters(p, filters))
      .sort((a, b) => b.score - a.score)
      .slice(0, 20)

    return new Response(JSON.stringify({ prospects: scored, count: scored.length }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
      },
    })
  } catch (error) {
    console.error("Search error:", error)
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 400,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
      },
    })
  }
})
