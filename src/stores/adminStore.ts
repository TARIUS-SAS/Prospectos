import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface AdminStats {
  costoReal: number
  ingresos: number
  margenBruto: number
  cacheHitRate: number
  ahorroTotal: number
}

export interface User {
  id: string
  email: string
  plan: string
  consumo: number
  estado: 'activo' | 'inactivo'
}

export const useAdminStore = defineStore('admin', () => {
  const stats = ref<AdminStats>({
    costoReal: 0,
    ingresos: 0,
    margenBruto: 0,
    cacheHitRate: 0,
    ahorroTotal: 0,
  })

  const users = ref<User[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  function setStats(newStats: Partial<AdminStats>) {
    stats.value = { ...stats.value, ...newStats }
  }

  function setUsers(newUsers: User[]) {
    users.value = newUsers
  }

  function addUser(user: User) {
    users.value.push(user)
  }

  return {
    stats,
    users,
    isLoading,
    error,
    setStats,
    setUsers,
    addUser,
  }
})
