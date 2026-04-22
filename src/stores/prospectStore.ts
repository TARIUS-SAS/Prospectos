import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface Prospect {
  id: string
  nombre: string
  dirección: string
  teléfono?: string
  website?: string
  https?: boolean
  google_rating?: number
  score: number
  es_caliente: boolean
}

export const useProspectStore = defineStore('prospect', () => {
  const prospects = ref<Prospect[]>([])
  const currentProspect = ref<Prospect | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  function setProspects(items: Prospect[]) {
    prospects.value = items.sort((a, b) => b.score - a.score)
  }

  function setCurrentProspect(prospect: Prospect) {
    currentProspect.value = prospect
  }

  function addProspect(prospect: Prospect) {
    const exists = prospects.value.find(p => p.id === prospect.id)
    if (!exists) {
      prospects.value.push(prospect)
      prospects.value.sort((a, b) => b.score - a.score)
    }
  }

  function clearProspects() {
    prospects.value = []
    currentProspect.value = null
  }

  return {
    prospects,
    currentProspect,
    isLoading,
    error,
    setProspects,
    setCurrentProspect,
    addProspect,
    clearProspects,
  }
})
