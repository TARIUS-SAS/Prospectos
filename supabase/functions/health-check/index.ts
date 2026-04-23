import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("", {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, content-type, apikey",
      },
    })
  }

  return new Response(JSON.stringify({ status: "ok", timestamp: new Date().toISOString() }), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  })
})
