<template>
  <div class="sidebar">
    <div class="sidebar-brand">
      <span class="dot"></span>
      <div>
        <div style="font-weight: 700; font-size: 14px;">PROSPECTOR</div>
        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">{{ userPlan }}</div>
      </div>
    </div>

    <nav class="sidebar-nav">
      <router-link
        v-for="item in visibleMenuItems"
        :key="item.path"
        :to="item.path"
        :class="['sidebar-nav-item', { active: isActive(item.path) }]"
      >
        <span style="font-size: 16px;">{{ item.icon }}</span>
        <span>{{ item.label }}</span>
      </router-link>
    </nav>

    <div class="sidebar-status">
      <div class="status-item">
        <span class="dot"></span>
        <div>
          <div style="font-weight: 600;">Sistema activo</div>
          <div style="font-size: 10px; color: var(--text-muted);">Prospector en tiempo real</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/authStore'

const route = useRoute()
const authStore = useAuthStore()

const menuItems = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/search', label: 'Nueva búsqueda', icon: '🔍' },
  { path: '/history', label: 'Mis búsquedas', icon: '📂' },
  { path: '/saved', label: 'Guardados', icon: '💾' },
  { path: '/settings', label: 'Configuración', icon: '⚙️' },
  { path: '/admin', label: 'Admin', icon: '🔐' },
]

const userPlan = computed(() => authStore.user?.plan || 'Pro')

const visibleMenuItems = computed(() => {
  return menuItems.filter(item => {
    if (item.path === '/admin') {
      return authStore.isAdmin
    }
    return true
  })
})

function isActive(path: string) {
  return route.path === path
}
</script>
