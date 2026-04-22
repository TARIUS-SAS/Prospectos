import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

export const user = ref<any>(null)
export const isAdmin = computed(() => user.value?.raw_app_meta_data?.role === 'admin')
export const isLoading = ref(false)
export const error = ref<string | null>(null)

export function useAuth() {
  const router = useRouter()

  async function login(email: string, password: string) {
    isLoading.value = true
    error.value = null
    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      if (authError) throw authError
      user.value = data.user
      await router.push('/dashboard')
    } catch (err: any) {
      error.value = err.message || 'Error al iniciar sesión'
    } finally {
      isLoading.value = false
    }
  }

  async function logout() {
    isLoading.value = true
    try {
      await supabase.auth.signOut()
      user.value = null
      await router.push('/login')
    } finally {
      isLoading.value = false
    }
  }

  async function checkAuth() {
    isLoading.value = true
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser()
      user.value = authUser
      if (!authUser) {
        await router.push('/login')
      }
    } finally {
      isLoading.value = false
    }
  }

  return {
    user,
    isAdmin,
    isLoading,
    error,
    login,
    logout,
    checkAuth,
  }
}
