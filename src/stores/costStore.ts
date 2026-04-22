import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useSupabase } from '../composables/useSupabase'

export interface DailyCost {
  búsquedas: number
  empresas: number
  guardados: number
  total: number
}

export interface MonthlyCost extends DailyCost {}

export const useCostStore = defineStore('cost', () => {
  const supabase = useSupabase()

  const dailyCost = ref<DailyCost>({
    búsquedas: 0,
    empresas: 0,
    guardados: 0,
    total: 0,
  })

  const monthlyCost = ref<MonthlyCost>({
    búsquedas: 0,
    empresas: 0,
    guardados: 0,
    total: 0,
  })

  const costHistory = ref<any[]>([])

  // Config costs
  const costPerSearch = ref<number>(0.50)
  const costPerUpdate = ref<number>(0.10)
  const minMargin = ref<number>(30)

  function updateDailyCost(updates: Partial<DailyCost>) {
    dailyCost.value = { ...dailyCost.value, ...updates }
    dailyCost.value.total =
      dailyCost.value.búsquedas +
      dailyCost.value.empresas +
      dailyCost.value.guardados
  }

  function updateMonthlyCost(updates: Partial<MonthlyCost>) {
    monthlyCost.value = { ...monthlyCost.value, ...updates }
    monthlyCost.value.total =
      monthlyCost.value.búsquedas +
      monthlyCost.value.empresas +
      monthlyCost.value.guardados
  }

  function addToHistory(entry: any) {
    costHistory.value.push(entry)
  }

  function clearHistory() {
    costHistory.value = []
  }

  async function loadConfig() {
    try {
      const { data } = await supabase.client
        .from('admin_config')
        .select('clave, valor')

      if (data) {
        data.forEach((item: any) => {
          if (item.clave === 'costo_por_búsqueda') costPerSearch.value = item.valor
          if (item.clave === 'costo_por_actualización') costPerUpdate.value = item.valor
          if (item.clave === 'margen_mínimo_percent') minMargin.value = item.valor
        })
      }
    } catch (error) {
      console.error('Error loading cost config:', error)
    }
  }

  return {
    dailyCost,
    monthlyCost,
    costHistory,
    costPerSearch,
    costPerUpdate,
    minMargin,
    updateDailyCost,
    updateMonthlyCost,
    addToHistory,
    clearHistory,
    loadConfig,
  }
})
