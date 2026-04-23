import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useSupabase } from '../composables/useSupabase'
import { user } from '../composables/useAuth'

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
    // Se permite búsqueda con solo sri_activo (búsqueda general de prospectos activos)
    // O si algún filtro específico está configurado
    const hasSpecificFilters = [
      filters.value.zona,
      filters.value.tipo_negocio,
      filters.value.palabra_clave,
      filters.value.empleados_range,
      filters.value.presencia_web
    ].some(f => f && f !== '')
    return hasSpecificFilters || filters.value.sri_activo
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
      // Call Google Places Edge Function with authentication
      const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY
      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/search-google-places`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${anonKey}`,
          'apikey': anonKey,
        },
        body: JSON.stringify({
          query: filters.value.palabra_clave || filters.value.tipo_negocio || 'negocios',
          zona: filters.value.zona || 'Centro',
          tipo_negocio: filters.value.tipo_negocio,
          empleados_range: filters.value.empleados_range,
          presencia_web: filters.value.presencia_web,
          cantidad_resultados: filters.value.cantidad_resultados
        })
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      const data = await response.json()

      // Google Places Edge Function retorna resultados con ID de búsqueda
      results.value = data.resultados || []

      // El Edge Function ya registra la búsqueda en la BD
      if (data.búsqueda_id) {
        lastSearchId.value = data.búsqueda_id
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
