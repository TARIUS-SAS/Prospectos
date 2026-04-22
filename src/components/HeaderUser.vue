<template>
  <div style="display: flex; align-items: center; gap: 16px;">
    <div style="text-align: right;">
      <div style="font-size: 12px; color: var(--text-muted);">{{ email }}</div>
    </div>
    <button @click="showConfirm = true" class="btn btn-secondary" style="padding: 8px 12px; font-size: 12px;">
      Cerrar sesión
    </button>

    <!-- Modal confirm -->
    <div v-if="showConfirm" style="position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000;">
      <div class="panel" style="padding: 24px; max-width: 300px;">
        <div style="margin-bottom: 16px; font-weight: 600;">¿Cerrar sesión?</div>
        <div style="display: flex; gap: 8px;">
          <button @click="handleLogout" class="btn btn-primary" style="flex: 1;">Sí</button>
          <button @click="showConfirm = false" class="btn btn-secondary" style="flex: 1;">No</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '../stores/authStore'

const authStore = useAuthStore()
const showConfirm = ref(false)

const email = authStore.user?.email || 'usuario'

async function handleLogout() {
  await authStore.logout()
  showConfirm.value = false
}
</script>
