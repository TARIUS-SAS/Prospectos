<template>
  <div class="min-h-screen bg-[#e8d8cb] flex items-center justify-center p-4">
    <div class="bg-white rounded-lg shadow-lg max-w-md w-full p-8">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-[#b87333] mb-2">PROSPECTOR</h1>
        <p class="text-[#6b7280]">Encuentra clientes sin web</p>
      </div>

      <form @submit.prevent="handleLogin" class="space-y-4">
        <Input
          v-model="form.email"
          type="email"
          label="Email"
          placeholder="tu@email.com"
          required
          :error="emailError"
        />

        <Input
          v-model="form.password"
          type="password"
          label="Contraseña"
          placeholder="••••••••"
          required
          :error="passwordError"
        />

        <div v-if="error" class="bg-red-50 border-l-4 border-[#ef4444] p-4 text-[#ef4444] text-sm">
          {{ error }}
        </div>

        <Button
          variant="primary"
          type="submit"
          :disabled="isLoading"
          class="w-full"
        >
          {{ isLoading ? 'Entrando...' : 'ENTRAR' }}
        </Button>
      </form>

      <div class="mt-6 text-center text-sm text-[#6b7280]">
        ¿No tienes cuenta?
        <a href="#" class="text-[#b87333] font-medium hover:underline">
          Contacta a Tarius SAS
        </a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from './../stores/authStore'
import Input from './../components/common/Input.vue'
import Button from './../components/common/Button.vue'

const authStore = useAuthStore()

const form = ref({
  email: '',
  password: '',
})

const emailError = ref('')
const passwordError = ref('')
const error = ref('')
const isLoading = ref(false)

function validateForm() {
  emailError.value = ''
  passwordError.value = ''

  if (!form.value.email) {
    emailError.value = 'Email requerido'
  }
  if (!form.value.password) {
    passwordError.value = 'Contraseña requerida'
  }

  return !emailError.value && !passwordError.value
}

async function handleLogin() {
  if (!validateForm()) return

  isLoading.value = true
  error.value = ''

  try {
    await authStore.login(form.value.email, form.value.password)
  } catch (err: any) {
    error.value = err.message || 'Error al iniciar sesión'
  } finally {
    isLoading.value = false
  }
}
</script>
