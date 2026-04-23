import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useSupabase } from '../composables/useSupabase'

export const useSearchStore = defineStore('search', () => {
  const supabase = useSupabase()

  // State
  const filters = ref({
    zona: '',
    tipo_negocio: '',
    palabra_clave: '',
    empleados_range: '',
    presencia_web: '',
    sri_activo: true,
    cantidad_resultados: 20
  })

  const results = ref<any[]>([])
  const searchHistory = ref<any[]>([])
  const loading = ref(false)
  const error = ref('')
  const lastSearchId = ref<string | null>(null)

  // Computed
  const hasFilters = computed(() => {
    return Object.values(filters.value).some(v => v === true || (v !== '' && v !== false))
  })

  const resultCount = computed(() => results.value.length)

  const hotProspects = computed(() => {
    return results.value.filter((p: any) => p.score >= 70)
  })

  // Actions
  async function performSearch() {
    if (!hasFilters.value) return

    loading.value = true
    error.value = ''

    try {
      // Call Edge Function
      const { data, error: err } = await supabase.client.functions.invoke('search-prospects', {
        body: filters.value
      })

      if (err) throw err

      results.value = data.prospects || []
      const scoreAvg = results.value.length > 0
        ? (results.value.reduce((sum: number, p: any) => sum + p.score, 0) / results.value.length).toFixed(2)
        : 0

      // Save search to DB
      const { data: searchData, error: searchErr } = await supabase.client
        .from('searches')
        .insert({
          zona: filters.value.zona || null,
          tipo_negocio: filters.value.tipo_negocio || null,
          palabra_clave: filters.value.palabra_clave || null,
          empleados_range: filters.value.empleados_range || null,
          presencia_web: filters.value.presencia_web || null,
          sri_activo: filters.value.sri_activo,
          cantidad_resultados: resultCount.value,
          score_promedio: scoreAvg
        })
        .select()

      if (searchErr) throw searchErr

      if (searchData && searchData.length > 0) {
        lastSearchId.value = searchData[0].id
      }

      // Load history
      await loadSearchHistory()
    } catch (e: any) {
      error.value = e.message || 'Error en la búsqueda'
      console.error('Search error:', e)
    } finally {
      loading.value = false
    }
  }

  async function loadSearchHistory() {
    try {
      const { data, error: err } = await supabase.client
        .from('searches')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(20)

      if (err) throw err
      searchHistory.value = data || []
    } catch (e: any) {
      console.error('Error loading history:', e)
    }
  }

  function clearFilters() {
    filters.value = {
      zona: '',
      tipo_negocio: '',
      palabra_clave: '',
      empleados_range: '',
      presencia_web: '',
      sri_activo: true,
      cantidad_resultados: 20
    }
    results.value = []
    error.value = ''
  }

  async function replaySearch(searchId: string) {
    try {
      const { data } = await supabase.client
        .from('searches')
        .select('*')
        .eq('id', searchId)
        .single()

      if (data) {
        filters.value = {
          zona: data.zona || '',
          tipo_negocio: data.tipo_negocio || '',
          palabra_clave: data.palabra_clave || '',
          empleados_range: data.empleados_range || '',
          presencia_web: data.presencia_web || '',
          sri_activo: data.sri_activo ?? true
        }
        await performSearch()
      }
    } catch (e: any) {
      error.value = e.message || 'Error al repetir búsqueda'
    }
  }

  function exportCSV() {
    if (results.value.length === 0) return

    const headers = ['Nombre', 'Dirección', 'Teléfono', 'Website', 'Rating', 'Reviews', 'Score']
    const rows = results.value.map((p: any) => [
      p.nombre,
      p.direccion,
      p.telefono,
      p.website || '',
      p.google_rating || '',
      p.google_reviews || '',
      p.score
    ])

    const csv = [headers, ...rows]
      .map(row => row.map((cell: any) => `"${cell}"`).join(','))
      .join('\n')

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)

    link.setAttribute('href', url)
    link.setAttribute('download', `prospector-${new Date().toISOString().split('T')[0]}.csv`)
    link.click()
  }

  return {
    // State
    filters,
    results,
    searchHistory,
    loading,
    error,
    lastSearchId,

    // Computed
    hasFilters,
    resultCount,
    hotProspects,

    // Actions
    performSearch,
    loadSearchHistory,
    clearFilters,
    replaySearch,
    exportCSV
  }
})
