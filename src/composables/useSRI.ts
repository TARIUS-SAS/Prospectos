import { useSupabase } from './useSupabase'

export interface SRIRequest {
  empresa_nombres: string[]
  provincia?: string
}

export function useSRI() {
  const supabase = useSupabase()

  async function querySRI(request: SRIRequest) {
    try {
      const result = await supabase.callEdgeFunction('query-sri', request)
      return result
    } catch (error) {
      console.error('Error querying SRI:', error)
      throw error
    }
  }

  return {
    querySRI,
  }
}
