<template>
  <header class="bg-white border-b border-gray-200 shadow-sm">
    <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-2xl font-bold text-copper font-display">PROSPECTOR</span>
      </div>

      <nav class="hidden md:flex gap-8">
        <router-link
          to="/dashboard"
          class="text-navy hover:text-copper transition-colors duration-300 text-sm font-medium"
        >
          Dashboard
        </router-link>
        <router-link
          to="/history"
          class="text-navy hover:text-copper transition-colors duration-300 text-sm font-medium"
        >
          Mis búsquedas
        </router-link>
        <router-link
          to="/saved"
          class="text-navy hover:text-copper transition-colors duration-300 text-sm font-medium"
        >
          Guardados
        </router-link>
        <router-link
          v-if="authStore.isAdmin"
          to="/admin"
          class="text-navy hover:text-copper transition-colors duration-300 text-sm font-medium"
        >
          Admin
        </router-link>
      </nav>

    </div>
  </header>
</template>

<script setup lang="ts">
import { useAuthStore } from '../../stores/authStore'

const authStore = useAuthStore()
</script>
