import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") || "http://localhost:5173",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type",
}

interface SRIRequest {
  empresa_nombres: string[]
  provincia?: string
}

interface SRIResultado {
  empresa_nombre: string
  ruc?: string
  estado?: string
  actividad_economica?: string
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

    const body: SRIRequest = await req.json()

    if (!body.empresa_nombres || body.empresa_nombres.length === 0) {
      return new Response(
        JSON.stringify({ error: "empresa_nombres es requerido" }),
        { status: 400, headers: corsHeaders }
      )
    }

    // Aquí iría la consulta a tabla RUC pública de SRI
    // Por ahora, retorna estructura (será implementado en fase 2)
    const resultados: SRIResultado[] = body.empresa_nombres.map((nombre) => ({
      empresa_nombre: nombre,
      ruc: null,
      estado: "no_encontrado",
      actividad_economica: null,
    }))

    // Calcular costo real
    const { data: costSettings } = await supabase
      .from("admin_settings")
      .select("valor")
      .eq("clave", "costo_sri_per_query")
      .single()

    const costoReal = parseFloat(costSettings?.valor || "0.001")

    return new Response(
      JSON.stringify({
        resultados,
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
