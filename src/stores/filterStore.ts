import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Filter {
  id: string
  field: 'zona' | 'tipo_negocio' | 'nombre' | 'empleados_range' | 'presencia_web'
  value: string
}

export const useFilterStore = defineStore('filter', () => {
  const filters = ref<Filter[]>([])
  const nextId = ref<number>(0)

  const filterCount = computed(() => filters.value.length)

  const isValidToSearch = computed(() => filterCount.value > 0)

  function addFilter(field: Filter['field'], value: string) {
    if (value.trim()) {
      filters.value.push({
        id: String(nextId.value++),
        field,
        value,
      })
    }
  }

  function removeFilter(id: string) {
    // Prevent removing if last filter
    if (filters.value.length > 1) {
      filters.value = filters.value.filter(f => f.id !== id)
    }
  }

  function updateFilter(id: string, value: string) {
    const filter = filters.value.find(f => f.id === id)
    if (filter) {
      filter.value = value
    }
  }

  function clearFilters() {
    filters.value = []
    nextId.value = 0
  }

  function getFiltersForRequest() {
    const result: Record<string, string> = {}
    filters.value.forEach(f => {
      if (!result[f.field]) {
        result[f.field] = f.value
      }
    })
    return result
  }

  return {
    filters,
    filterCount,
    isValidToSearch,
    addFilter,
    removeFilter,
    updateFilter,
    clearFilters,
    getFiltersForRequest,
  }
})
