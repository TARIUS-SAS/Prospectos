import { useSupabase } from './useSupabase'

export function useScoring() {
  const supabase = useSupabase()

  async function calculateScore(prospect: any) {
    // Centralizar en Edge Function para evitar duplicación (verdad única)
    try {
      const result = await supabase.callEdgeFunction('calculate-score', prospect)
      return result
    } catch (error) {
      console.error('Error calculating score:', error)
      throw error
    }
  }

  return {
    calculateScore,
  }
}
