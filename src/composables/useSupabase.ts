import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

// Whitelist de Edge Functions permitidas (previene acceso a funciones no-autorizadas)
const ALLOWED_FUNCTIONS = ['calculate-score', 'search-google-places', 'query-sri']

export function useSupabase() {
  return {
    client: supabase,

    async callEdgeFunction<T>(
      functionName: string,
      payload: any
    ): Promise<T> {
      // Validar que la función está en whitelist (no permitir funciones arbitrarias)
      if (!ALLOWED_FUNCTIONS.includes(functionName)) {
        throw new Error(`Función no permitida: ${functionName}`)
      }

      const { data, error } = await supabase.functions.invoke(functionName, {
        body: payload,
      })

      if (error) throw error
      return data as T
    },

    async getOrInsertProspect(prospect: any) {
      const { data: existing } = await supabase
        .from('prospects')
        .select('id')
        .eq('nombre', prospect.nombre)
        .eq('dirección', prospect.dirección)
        .maybeSingle()

      if (existing) {
        return existing.id
      }

      const { data, error } = await supabase
        .from('prospects')
        .insert([prospect])
        .select('id')
        .single()

      // Manejar race condition: si otro usuario insertó entre nuestro SELECT y INSERT
      if (error) {
        if (error.code === '23505') {
          // UNIQUE constraint violation: fue insertado por otro usuario concurrentemente
          // Reintentar SELECT para obtener su ID
          const { data: inserted } = await supabase
            .from('prospects')
            .select('id')
            .eq('nombre', prospect.nombre)
            .eq('dirección', prospect.dirección)
            .single()

          if (inserted) {
            return inserted.id
          }
        }
        throw error
      }

      return data.id
    },

    async createProspectVersion(prospectId: string, data: any) {
      // Validar: solo permitir campos específicos de prospect (previene mass assignment)
      const allowedFields = [
        'nombre', 'dirección', 'teléfono', 'website', 'https',
        'facebook_instagram', 'google_rating', 'google_reviews_count',
        'tipo_negocio', 'empleados_estimados', 'sri_activo',
        'latitude', 'longitude', 'score', 'desglose_score',
        'usuario_actualizo', 'cambios_json'
      ]

      const versionData: any = {
        prospect_id: prospectId,
        version_number: 1,
        razon: 'búsqueda_inicial',
      }

      // Copiar solo campos permitidos
      for (const field of allowedFields) {
        if (field in data) {
          versionData[field] = data[field]
        }
      }

      const { error } = await supabase
        .from('prospect_versions')
        .insert([versionData])

      if (error) throw error
    },

    async logCost(userId: string, costData: any) {
      // Validar: solo permitir campos específicos de cost (previene mass assignment)
      const allowedFields = [
        'búsqueda_id', 'tipo_operacion', 'cantidad',
        'costo_unitario_real', 'costo_unitario_venta',
        'costo_total_real', 'costo_total_venta',
        'margen_absoluto', 'margen_porcentaje'
      ]

      const logData: any = {
        usuario_id: userId,
      }

      // Copiar solo campos permitidos
      for (const field of allowedFields) {
        if (field in costData) {
          logData[field] = costData[field]
        }
      }

      const { error } = await supabase
        .from('cost_logs')
        .insert([logData])

      if (error) throw error
    },

    async logAccess(accessData: any) {
      // Validar: solo permitir campos específicos de access log (previene mass assignment)
      const allowedFields = [
        'prospect_id', 'usuario_id', 'búsqueda_id',
        'origen', 'costo_real', 'costo_venta'
      ]

      const logData: any = {}

      // Copiar solo campos permitidos
      for (const field of allowedFields) {
        if (field in accessData) {
          logData[field] = accessData[field]
        }
      }

      const { error } = await supabase
        .from('prospect_access_log')
        .insert([logData])

      if (error) throw error
    },
  }
}
