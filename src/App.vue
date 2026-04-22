<template>
  <div :class="authStore.user ? 'app-layout' : ''">
    <!-- Sidebar (solo si está autenticado) -->
    <Sidebar v-if="authStore.user" />

    <!-- Main content -->
    <div :class="authStore.user ? 'app-wrapper' : ''">
      <!-- Header con usuario (solo si autenticado) -->
      <div v-if="authStore.user" style="display: flex; justify-content: space-between; align-items: center; padding: 16px 24px; background: var(--ink-1); border-bottom: 1px solid var(--line); position: sticky; top: 0; z-index: 100;">
        <div></div>
        <HeaderUser />
      </div>

      <!-- Page content -->
      <div :class="authStore.user ? 'app-content' : ''">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from './stores/authStore'
import Sidebar from './components/layout/Sidebar.vue'
import HeaderUser from './components/HeaderUser.vue'
import './styles/globals.css'

const authStore = useAuthStore()

onMounted(() => {
  authStore.initAuth()
})
</script>

<style scoped>
.app-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
}
</style>
