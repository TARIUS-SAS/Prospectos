<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Hola, {{ userName }}</p>
        <h1>Dashboard</h1>
      </div>
    </div>

    <div class="page-main">
      <!-- Stats Grid -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-label">Búsquedas hoy</div>
          <div class="stat-number">{{ searchesToday }}</div>
          <p class="stat-detail">{{ searchHistory.length > 0 ? 'Últimas 24h' : 'Sin búsquedas' }}</p>
        </div>

        <div class="stat-card">
          <div class="stat-label">Prospectos encontrados</div>
          <div class="stat-number">{{ totalProspectsFound }}</div>
          <p class="stat-detail">en todas tus búsquedas</p>
        </div>

        <div class="stat-card hot">
          <div class="stat-label">Prospectos calientes</div>
          <div class="stat-number">{{ hotProspectsCount }}</div>
          <p class="stat-detail">score ≥ 70</p>
        </div>

        <div class="stat-card">
          <div class="stat-label">Guardados</div>
          <div class="stat-number">{{ savedProspectsCount }}</div>
          <p class="stat-detail">en tu CRM</p>
        </div>
      </div>

      <!-- Next Action + Recent Searches -->
      <div class="dashboard-sections">
        <!-- Next Action -->
        <div v-if="nextAction" class="section">
          <h3>Próxima acción</h3>
          <div class="next-action-card">
            <div class="action-main">
              <p class="action-prospect">{{ nextAction.prospect?.nombre }}</p>
              <p class="action-notes">{{ nextAction.notas || '(sin notas)' }}</p>
            </div>
            <div class="action-meta">
              <span class="action-date">{{ formatDate(nextAction.proxima_accion) }}</span>
              <span :class="['action-status', nextAction.estado.toLowerCase()]">
                {{ nextAction.estado }}
              </span>
            </div>
          </div>
        </div>

        <!-- Recent Searches -->
        <div class="section">
          <h3>Búsquedas recientes</h3>
          <div v-if="searchHistory.length > 0" class="search-history-list">
            <div
              v-for="search in searchHistory.slice(0, 5)"
              :key="search.id"
              class="history-item"
              @click="() => replaySearch(search.id)"
            >
              <div class="history-main">
                <p class="history-tipo">{{ search.tipo_negocio }}</p>
                <p class="history-meta">{{ search.cantidad_resultados }} resultados • Score prom: {{ search.score_promedio }}</p>
              </div>
              <p class="history-date">{{ formatDateShort(search.created_at) }}</p>
            </div>
          </div>
          <div v-else class="empty-state">
            <p>Aún no has hecho búsquedas</p>
            <router-link to="/search" class="link-button">Ir a búsqueda</router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useSearchStore } from '../stores/searchStore'
import { useSavedStore } from '../stores/savedStore'
import { useAuthStore } from '../stores/authStore'
import { useRouter } from 'vue-router'

const searchStore = useSearchStore()
const savedStore = useSavedStore()
const authStore = useAuthStore()
const router = useRouter()

// Load data on mount
onMounted(async () => {
  await searchStore.loadSearchHistory()
  await savedStore.loadSaved()
})

// Computed values
const userName = computed(() => authStore.user?.user_metadata?.full_name || 'Usuario')
const searchHistory = computed(() => searchStore.searchHistory)
const nextAction = computed(() => savedStore.proxima)
const savedProspectsCount = computed(() => savedStore.saved.length)

const searchesToday = computed(() => {
  const today = new Date().toDateString()
  return searchHistory.value.filter(s => new Date(s.created_at).toDateString() === today).length
})

const totalProspectsFound = computed(() => {
  return searchHistory.value.reduce((sum: number, s: any) => sum + (s.cantidad_resultados || 0), 0)
})

const hotProspectsCount = computed(() => {
  return searchHistory.value.reduce((sum: number, s: any) => {
    const avgScore = s.score_promedio ? parseFloat(s.score_promedio) : 0
    return sum + (avgScore >= 70 ? 1 : 0)
  }, 0)
})

// Methods
function formatDate(date: string): string {
  if (!date) return 'Sin fecha'
  const d = new Date(date)
  return d.toLocaleDateString('es-EC', { month: 'short', day: 'numeric' })
}

function formatDateShort(date: string): string {
  const d = new Date(date)
  const today = new Date()
  const diffTime = today.getTime() - d.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays === 0) return 'Hoy'
  if (diffDays === 1) return 'Ayer'
  if (diffDays < 7) return `Hace ${diffDays}d`
  return d.toLocaleDateString('es-EC', { month: 'short', day: 'numeric' })
}

async function replaySearch(searchId: string) {
  await searchStore.replaySearch(searchId)
  if (!searchStore.error) {
    router.push('/search')
  }
}
</script>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.stat-card {
  background: var(--ink-2);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid var(--line);
  transition: all 200ms ease-out;
}

.stat-card:hover {
  border-color: var(--orange);
  box-shadow: 0 4px 12px rgba(255, 159, 67, 0.1);
}

.stat-card.hot {
  border-color: var(--orange);
  background: linear-gradient(135deg, var(--ink-1), rgba(255, 159, 67, 0.05));
}

.stat-label {
  font-size: 12px;
  color: var(--text-muted);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 8px;
}

.stat-number {
  font-size: 36px;
  font-weight: 700;
  color: var(--text);
  background: linear-gradient(135deg, var(--orange), #ff6b35);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 4px;
}

.stat-detail {
  margin: 0;
  font-size: 12px;
  color: var(--text-muted);
}

.dashboard-sections {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.section {
  background: var(--ink-2);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid var(--line);
}

.section h3 {
  margin-top: 0;
  margin-bottom: 16px;
  font-size: 16px;
  color: var(--text);
}

.next-action-card {
  background: var(--ink-1);
  padding: 16px;
  border-radius: 8px;
  border-left: 3px solid var(--orange);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.action-main {
  flex: 1;
}

.action-prospect {
  margin: 0 0 4px;
  font-size: 14px;
  font-weight: 600;
  color: var(--text);
}

.action-notes {
  margin: 0;
  font-size: 12px;
  color: var(--text-muted);
}

.action-meta {
  display: flex;
  gap: 8px;
  align-items: center;
  text-align: right;
}

.action-date {
  font-size: 11px;
  color: var(--text-muted);
  font-weight: 500;
}

.action-status {
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 11px;
  font-weight: 600;
}

.action-status.nuevo {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.action-status.contactado {
  background: rgba(245, 158, 11, 0.2);
  color: #f59e0b;
}

.action-status.interesado {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.action-status.ganado {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.search-history-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.history-item {
  background: var(--ink-1);
  padding: 12px;
  border-radius: 6px;
  border: 1px solid var(--line);
  cursor: pointer;
  transition: all 200ms;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.history-item:hover {
  border-color: var(--orange);
  background: rgba(255, 159, 67, 0.02);
}

.history-main {
  flex: 1;
}

.history-tipo {
  margin: 0;
  font-size: 13px;
  font-weight: 600;
  color: var(--text);
}

.history-meta {
  margin: 2px 0 0;
  font-size: 11px;
  color: var(--text-muted);
}

.history-date {
  margin: 0;
  font-size: 11px;
  color: var(--text-muted);
  white-space: nowrap;
}

.empty-state {
  padding: 24px 16px;
  text-align: center;
  color: var(--text-muted);
}

.empty-state p {
  margin: 0 0 12px;
  font-size: 14px;
}

.link-button {
  display: inline-block;
  padding: 8px 16px;
  background: var(--orange);
  color: var(--ink-1);
  text-decoration: none;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  transition: all 150ms;
}

.link-button:hover {
  background: #ff6b35;
  transform: scale(1.05);
}

@media (max-width: 1024px) {
  .dashboard-sections {
    grid-template-columns: 1fr;
  }
}
</style>
