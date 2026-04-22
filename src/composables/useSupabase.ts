import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

export function useSupabase() {
  return {
    client: supabase,

    async callEdgeFunction<T>(
      functionName: string,
      payload: any
    ): Promise<T> {
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

      if (error) throw error
      return data.id
    },

    async createProspectVersion(prospectId: string, data: any) {
      const { error } = await supabase
        .from('prospect_versions')
        .insert([{
          prospect_id: prospectId,
          version_number: 1,
          ...data,
          razon: 'búsqueda_inicial',
        }])

      if (error) throw error
    },

    async logCost(userId: string, costData: any) {
      const { error } = await supabase
        .from('cost_logs')
        .insert([{
          usuario_id: userId,
          ...costData,
        }])

      if (error) throw error
    },

    async logAccess(accessData: any) {
      const { error } = await supabase
        .from('prospect_access_log')
        .insert([accessData])

      if (error) throw error
    },
  }
}
