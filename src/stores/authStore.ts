import { defineStore } from 'pinia'
import { computed } from 'vue'
import { useAuth } from '../composables/useAuth'

export const useAuthStore = defineStore('auth', () => {
  const { user, userRole, isAdmin, isLoading, error, login, logout, checkAuth } = useAuth()

  const isAuthenticated = computed(() => !!user.value)

  async function initAuth() {
    await checkAuth()
  }

  return {
    user,
    userRole,
    isAdmin,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    initAuth,
  }
})
