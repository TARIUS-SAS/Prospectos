import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface DailyCost {
  búsquedas: number
  empresas: number
  guardados: number
  total: number
}

export interface MonthlyCost extends DailyCost {}

export const useCostStore = defineStore('cost', () => {
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

  return {
    dailyCost,
    monthlyCost,
    costHistory,
    updateDailyCost,
    updateMonthlyCost,
    addToHistory,
    clearHistory,
  }
})
