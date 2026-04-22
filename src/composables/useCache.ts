import { useSupabase } from './useSupabase'

export function useCache() {
  const supabase = useSupabase()

  async function getCachedProspect(nombre: string, dirección: string) {
    const { data } = await supabase.client
      .from('prospects')
      .select('*')
      .eq('nombre', nombre)
      .eq('dirección', dirección)
      .maybeSingle()

    if (!data) return null

    const daysOld = (Date.now() - new Date(data.fecha_ultima_actualizacion).getTime()) / (1000 * 60 * 60 * 24)

    return {
      prospect: data,
      daysOld,
      isFresh: daysOld < 60,
      isStale: daysOld >= 60,
    }
  }

  async function cacheProspects(prospects: any[]) {
    const newProspects = []
    const cachedProspects = []

    // Parallelizar queries de caché con allSettled para resilencia (una falla no bloquea otras)
    const cacheResults = await Promise.allSettled(
      prospects.map(p => getCachedProspect(p.nombre, p.dirección))
    )

    cacheResults.forEach((result, index) => {
      if (result.status === 'fulfilled' && result.value && result.value.isFresh) {
        cachedProspects.push(result.value.prospect)
      } else {
        newProspects.push(prospects[index])
      }
    })

    return { newProspects, cachedProspects }
  }

  return {
    getCachedProspect,
    cacheProspects,
  }
}
