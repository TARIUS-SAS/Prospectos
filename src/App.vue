<template>
  <div :class="authStore.user ? 'app-layout' : ''">
    <!-- Sidebar (solo si está autenticado) -->
    <Sidebar v-if="authStore.user" />

    <!-- Main content -->
    <div :class="authStore.user ? 'app-wrapper' : ''">
  
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
