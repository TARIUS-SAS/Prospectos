<template>
  <div class="login-wrap">
    <!-- Visual side -->
    <div class="login-visual">
      <div class="scope"></div>
      <div class="content">
        <div class="sidebar-brand" style="font-size: 13px;">
          <span class="dot"></span>
          <span>Tarius SAS</span>
        </div>
        <h1 style="margin-top: 32px;">Encuentra<br>negocios <em>sin</em><br>presencia web.</h1>
        <p>Prospector identifica comercios en Ecuador sin website, los prioriza con score y te entrega listas listas para contactar.</p>
      </div>
      <div class="login-visual-tags">
        <span class="tag accent">● EN VIVO</span>
        <span class="tag">Google Places API</span>
        <span class="tag">SRI Ecuador</span>
        <span class="tag">Score 0—24</span>
      </div>
    </div>

    <!-- Form side -->
    <div class="login-form-side">
      <div class="login-form">
        <div class="login-logo">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="7"/>
            <line x1="21" y1="21" x2="16.5" y2="16.5"/>
          </svg>
        </div>
        <div class="login-title">Inicia sesión</div>
        <p class="login-subtitle">Accede a tu panel de prospección B2B.</p>

        <form @submit.prevent="handleLogin">
          <div class="field">
            <label>Correo electrónico</label>
            <div class="input-wrap">
              <span class="prefix">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><polyline points="22,6 12,13 2,6"/></svg>
              </span>
              <input v-model="form.email" type="email" class="input with-prefix" placeholder="tu@empresa.com" required>
            </div>
            <p v-if="emailError" class="field error">{{ emailError }}</p>
          </div>

          <div class="field">
            <label>Contraseña</label>
            <div class="input-wrap">
              <span class="prefix">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
              </span>
              <input v-model="form.password" type="password" class="input with-prefix" placeholder="••••••••••" required>
            </div>
            <p v-if="passwordError" class="field error">{{ passwordError }}</p>
          </div>

          <div class="checkbox-row">
            <label class="checkbox">
              <input type="checkbox" v-model="rememberMe">
              Mantenerme conectado
            </label>
            <a href="#" style="color: var(--orange); font-size: 13px; font-weight: 500;">¿Olvidaste?</a>
          </div>

          <button type="submit" class="btn btn-primary btn-lg btn-block" :disabled="isLoading">
            <span v-if="!isLoading">Entrar al panel</span>
            <span v-else>Entrando...</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
          </button>

          <div v-if="generalError" style="color: var(--error); font-size: 13px; margin-top: 16px; text-align: center;">{{ generalError }}</div>
        </form>

        <div class="login-footer">
          ¿Aún no tienes cuenta?
          <a href="#">Contacta a Tarius SAS →</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useRouter } from 'vue-router'

const router = useRouter()
const authStore = useAuthStore()

const form = ref({
  email: 'mateo@tarius.ec',
  password: '••••••••••••',
})

const emailError = ref('')
const passwordError = ref('')
const generalError = ref('')
const isLoading = ref(false)
const rememberMe = ref(true)

function validateForm() {
  emailError.value = ''
  passwordError.value = ''

  if (!form.value.email) {
    emailError.value = 'Correo requerido'
  } else if (!form.value.email.includes('@')) {
    emailError.value = 'Correo inválido'
  }

  if (!form.value.password) {
    passwordError.value = 'Contraseña requerida'
  }

  return !emailError.value && !passwordError.value
}

async function handleLogin() {
  if (!validateForm()) return

  isLoading.value = true
  generalError.value = ''

  try {
    await authStore.login(form.value.email, form.value.password)
    router.push('/dashboard')
  } catch (err: any) {
    generalError.value = err.message || 'Error al iniciar sesión'
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
.login-visual-tags {
  position: relative;
  z-index: 1;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.tag {
  padding: 6px 14px;
  border: 1px solid var(--line);
  background: rgba(30, 45, 61, 0.5);
  backdrop-filter: blur(8px);
  border-radius: 999px;
  font-size: 11px;
  color: var(--text-dim);
  font-family: var(--font-mono);
  letter-spacing: 0.05em;
}

.tag.accent {
  color: var(--orange);
  border-color: var(--orange-line);
}
</style>
