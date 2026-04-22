<template>
  <header class="bg-white border-b-2 border-[#d4c4bb] mb-8">
    <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-2xl font-bold text-[#b87333]">PROSPECTOR</span>
      </div>

      <nav class="hidden md:flex gap-6">
        <router-link to="/dashboard" class="text-[#1a2735] hover:text-[#b87333] transition-colors">
          Dashboard
        </router-link>
        <router-link to="/history" class="text-[#1a2735] hover:text-[#b87333] transition-colors">
          Mis búsquedas
        </router-link>
        <router-link to="/saved" class="text-[#1a2735] hover:text-[#b87333] transition-colors">
          Guardados
        </router-link>
        <router-link to="/admin" v-if="authStore.isAdmin" class="text-[#1a2735] hover:text-[#b87333] transition-colors">
          Admin
        </router-link>
      </nav>

      <div class="flex items-center gap-4">
        <div class="text-right">
          <p class="text-sm font-medium text-[#1a2735]">{{ authStore.user?.email }}</p>
          <p v-if="authStore.isAdmin" class="text-xs text-[#b87333]">Admin</p>
        </div>
        <Button variant="secondary" @click="handleLogout">
          Logout
        </Button>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/authStore'
import Button from '@/components/common/Button.vue'

const authStore = useAuthStore()

async function handleLogout() {
  await authStore.logout()
}
</script>
