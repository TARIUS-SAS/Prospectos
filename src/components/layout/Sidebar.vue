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

    <div class="sidebar-footer">
      <div class="user-section">
        <div class="user-info">
          <div class="user-email">{{ authStore.user?.email }}</div>
          <div v-if="authStore.isAdmin" class="user-role">Admin</div>
        </div>
        <button @click="showLogoutConfirm = true" class="logout-btn">
          Cerrar sesión
        </button>
      </div>

      <div v-if="showLogoutConfirm" class="logout-modal">
        <div class="logout-modal-content">
          <div class="logout-modal-title">¿Cerrar sesión?</div>
          <div class="logout-modal-buttons">
            <button @click="handleLogout" class="btn-confirm">Sí</button>
            <button @click="showLogoutConfirm = false" class="btn-cancel">No</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/authStore'

const route = useRoute()
const authStore = useAuthStore()
const showLogoutConfirm = ref(false)

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

async function handleLogout() {
  await authStore.logout()
  showLogoutConfirm.value = false
}
</script>

<style scoped>
.sidebar {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: var(--ink-2);
  border-right: 1px solid var(--line);
  padding: 16px;
  width: 240px;
}

.sidebar-brand {
  display: flex;
  gap: 12px;
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--line);
}

.sidebar-brand .dot {
  width: 12px;
  height: 12px;
  background: var(--orange);
  border-radius: 50%;
  margin-top: 2px;
  flex-shrink: 0;
}

.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 24px;
}

.sidebar-nav-item {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 10px 12px;
  border-radius: 6px;
  color: var(--text-muted);
  text-decoration: none;
  font-size: 14px;
  transition: all 150ms;
  cursor: pointer;
}

.sidebar-nav-item:hover {
  background: rgba(255, 159, 67, 0.1);
  color: var(--text);
}

.sidebar-nav-item.active {
  background: rgba(255, 159, 67, 0.15);
  color: var(--orange);
  font-weight: 600;
}

.sidebar-status {
  margin-bottom: 24px;
  padding: 12px;
  background: rgba(255, 159, 67, 0.05);
  border-radius: 6px;
  border-left: 3px solid var(--orange);
}

.status-item {
  display: flex;
  gap: 12px;
}

.status-item .dot {
  width: 8px;
  height: 8px;
  background: #22c55e;
  border-radius: 50%;
  margin-top: 4px;
  flex-shrink: 0;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.sidebar-footer {
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid var(--line);
}

.user-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-info {
  padding: 12px;
  background: var(--ink-1);
  border-radius: 6px;
}

.user-email {
  font-size: 12px;
  color: var(--text);
  font-weight: 600;
  word-break: break-all;
}

.user-role {
  font-size: 10px;
  color: var(--orange);
  margin-top: 4px;
  font-weight: 600;
}

.logout-btn {
  width: 100%;
  padding: 8px 12px;
  background: var(--orange);
  color: var(--ink-1);
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 150ms;
}

.logout-btn:hover {
  background: #ff6b35;
  transform: scale(1.02);
}

.logout-modal {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.logout-modal-content {
  background: var(--ink-2);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 24px;
  max-width: 300px;
}

.logout-modal-title {
  font-weight: 600;
  color: var(--text);
  margin-bottom: 16px;
}

.logout-modal-buttons {
  display: flex;
  gap: 8px;
}

.btn-confirm,
.btn-cancel {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 150ms;
}

.btn-confirm {
  background: var(--orange);
  color: var(--ink-1);
}

.btn-confirm:hover {
  background: #ff6b35;
}

.btn-cancel {
  background: var(--ink-1);
  color: var(--text);
  border: 1px solid var(--line);
}

.btn-cancel:hover {
  border-color: var(--orange);
}
</style>
