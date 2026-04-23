import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useSupabase } from '../composables/useSupabase'

export const useSavedStore = defineStore('saved', () => {
  const supabase = useSupabase()

  // State
  const saved = ref<any[]>([])
  const loading = ref(false)
  const error = ref('')
  const filterEstado = ref('Todos')

  // Computed
  const filteredSaved = computed(() => {
    if (filterEstado.value === 'Todos') return saved.value
    return saved.value.filter((s: any) => s.estado === filterEstado.value)
  })

  const proximas = computed(() => {
    return saved.value
      .filter((s: any) => s.proxima_accion)
      .sort((a: any, b: any) => new Date(a.proxima_accion).getTime() - new Date(b.proxima_accion).getTime())
  })

  const proxima = computed(() => proximas.value[0] || null)

  // Actions
  async function loadSaved() {
    loading.value = true
    try {
      const { data, error: err } = await supabase.client
        .from('saved_prospects')
        .select('*, prospect:prospects(id, nombre, direccion, score, google_rating)')
        .order('proxima_accion', { ascending: true, nullsFirst: false })

      if (err) throw err
      saved.value = data || []
    } catch (e: any) {
      error.value = e.message || 'Error al cargar guardados'
      console.error('Load saved error:', e)
    } finally {
      loading.value = false
    }
  }

  async function saveProspect(prospect: any) {
    try {
      const { error: err } = await supabase.client
        .from('saved_prospects')
        .insert({
          prospect_id: prospect.id,
          estado: 'Nuevo',
          notas: ''
        })
        .select()

      if (err) throw err
      await loadSaved()
    } catch (e: any) {
      error.value = e.message || 'Error al guardar prospect'
      console.error('Save prospect error:', e)
    }
  }

  async function updateProspectStatus(savedId: string, estado: string, notas?: string, proxima_accion?: string) {
    try {
      const { error: err } = await supabase.client
        .from('saved_prospects')
        .update({
          estado,
          notas: notas || null,
          proxima_accion: proxima_accion || null
        })
        .eq('id', savedId)

      if (err) throw err
      await loadSaved()
    } catch (e: any) {
      error.value = e.message || 'Error al actualizar prospect'
      console.error('Update prospect error:', e)
    }
  }

  async function deleteProspect(savedId: string) {
    try {
      const { error: err } = await supabase.client
        .from('saved_prospects')
        .delete()
        .eq('id', savedId)

      if (err) throw err
      await loadSaved()
    } catch (e: any) {
      error.value = e.message || 'Error al eliminar prospect'
      console.error('Delete prospect error:', e)
    }
  }

  return {
    // State
    saved,
    loading,
    error,
    filterEstado,

    // Computed
    filteredSaved,
    proximas,
    proxima,

    // Actions
    loadSaved,
    saveProspect,
    updateProspectStatus,
    deleteProspect
  }
})
