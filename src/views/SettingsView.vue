<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Configuración</p>
        <h1>Preferencias</h1>
      </div>
    </div>

    <div class="page-main" style="max-width: 800px;">
      <div class="panel" style="margin-bottom: 16px;">
        <div class="panel-head">
          <h3>Cuenta</h3>
        </div>
        <div style="display: grid; gap: 16px;">
          <div class="field">
            <label>Email</label>
            <input type="email" class="input" :value="userEmail" disabled>
          </div>
          <div class="field">
            <label>Plan actual</label>
            <input type="text" class="input" :value="userPlan" disabled>
          </div>
          <button class="btn btn-secondary" @click="showPlanModal = true">Cambiar plan</button>
        </div>
      </div>

      <div class="panel" style="margin-bottom: 16px;">
        <div class="panel-head">
          <h3>Preferencias</h3>
        </div>
        <div style="display: grid; gap: 16px;">
          <div class="field">
            <label>Búsquedas máximas por día</label>
            <input type="number" v-model.number="preferences.maxSearchesPerDay" class="input" min="1" max="100">
          </div>
          <div class="field">
            <label>Resultados por defecto</label>
            <input type="number" v-model.number="preferences.defaultResults" class="input" min="1" max="100">
          </div>
          <button class="btn btn-primary" @click="savePreferences" :disabled="isSaving">
            {{ isSaving ? 'Guardando...' : 'Guardar preferencias' }}
          </button>
        </div>
      </div>

      <div class="panel">
        <div class="panel-head">
          <h3>Seguridad</h3>
        </div>
        <button class="btn btn-secondary" @click="showPasswordChange = !showPasswordChange">
          {{ showPasswordChange ? 'Cancelar' : 'Cambiar contraseña' }}
        </button>
        <div v-if="showPasswordChange" style="margin-top: 16px; display: grid; gap: 12px;">
          <div class="field">
            <label>Contraseña actual</label>
            <input type="password" class="input" v-model="passwordForm.current" placeholder="••••••••">
          </div>
          <div class="field">
            <label>Nueva contraseña</label>
            <input type="password" class="input" v-model="passwordForm.new" placeholder="••••••••">
          </div>
          <div class="field">
            <label>Confirmar contraseña</label>
            <input type="password" class="input" v-model="passwordForm.confirm" placeholder="••••••••">
          </div>
          <button class="btn btn-primary" @click="updatePassword" :disabled="isUpdatingPassword">
            {{ isUpdatingPassword ? 'Actualizando...' : 'Actualizar contraseña' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useSupabase } from '../composables/useSupabase'

const authStore = useAuthStore()
const supabase = useSupabase()

const showPasswordChange = ref(false)
const showPlanModal = ref(false)
const isSaving = ref(false)
const isUpdatingPassword = ref(false)

const preferences = ref({
  maxSearchesPerDay: 20,
  defaultResults: 20,
})

const passwordForm = ref({
  current: '',
  new: '',
  confirm: '',
})

const userEmail = computed(() => authStore.user?.email || '')
const userPlan = computed(() => authStore.user?.plan_name || 'Starter')

onMounted(() => {
  loadPreferences()
})

async function loadPreferences() {
  if (!authStore.user?.id) return

  try {
    const { data, error } = await supabase.client
      .from('users_metadata')
      .select('preferences')
      .eq('usuario_id', authStore.user.id)
      .single()

    if (error && error.code !== 'PGRST116') throw error

    if (data?.preferences) {
      preferences.value = data.preferences
    }
  } catch (error) {
    console.error('Error loading preferences:', error)
  }
}

async function savePreferences() {
  if (!authStore.user?.id) return

  isSaving.value = true
  try {
    const { error } = await supabase.client
      .from('users_metadata')
      .upsert({
        usuario_id: authStore.user.id,
        preferences: preferences.value,
        updated_at: new Date().toISOString(),
      })

    if (error) throw error
    // Show success message
  } catch (error) {
    console.error('Error saving preferences:', error)
  } finally {
    isSaving.value = false
  }
}

async function updatePassword() {
  if (passwordForm.value.new !== passwordForm.value.confirm) {
    alert('Las contraseñas no coinciden')
    return
  }

  isUpdatingPassword.value = true
  try {
    const { error } = await supabase.client.auth.updateUser({
      password: passwordForm.value.new,
    })

    if (error) throw error
    alert('Contraseña actualizada exitosamente')
    showPasswordChange.value = false
    passwordForm.value = { current: '', new: '', confirm: '' }
  } catch (error) {
    console.error('Error updating password:', error)
    alert('Error al actualizar la contraseña')
  } finally {
    isUpdatingPassword.value = false
  }
}
</script>
