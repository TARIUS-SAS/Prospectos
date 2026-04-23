import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useSupabase } from '../composables/useSupabase'

export const useSearchStore = defineStore('search', () => {
  const supabase = useSupabase()

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

  const resultCount = computed(() => results.value.length)

  const hotProspects = computed(() => {
    return results.value.filter((p: any) => p.score >= 70)
  })

  async function performSearch() {
    loading.value = true
    error.value = ''

    try {
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
          cantidad_resultados: filters.value.cantidad_resultados
        })
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      const data = await response.json()
      results.value = data.resultados || []

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

  function exportCSV() {
    if (results.value.length === 0) return

    const headers = ['Nombre', 'Dirección', 'Teléfono', 'Website', 'Rating', 'Reviews', 'Score']
    const rows = results.value.map((p: any) => [
      p.nombre,
      p.dirección,
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
    filters,
    results,
    searchHistory,
    loading,
    error,
    resultCount,
    hotProspects,
    performSearch,
    loadSearchHistory,
    clearFilters,
    exportCSV
  }
})
