<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Historial</p>
        <h1>Mis búsquedas</h1>
      </div>
    </div>

    <div class="page-main">
      <!-- Loading State -->
      <div v-if="loading" class="state-box">
        <div class="spinner"></div>
        <p>Cargando búsquedas...</p>
      </div>

      <!-- Results -->
      <div v-else-if="searchHistory.length > 0" class="history-list">
        <div v-for="search in searchHistory" :key="search.id" class="history-card">
          <div class="card-header">
            <div class="search-info">
              <h4 class="search-title">{{ getSearchTitle(search) }}</h4>
              <p class="search-meta">{{ search.cantidad_resultados }} resultados • Score promedio: {{ search.score_promedio }}</p>
            </div>
            <div class="search-date">{{ formatDate(search.created_at) }}</div>
          </div>

          <div class="card-footer">
            <button @click="replaySearch(search.id)" class="btn btn-sm btn-primary">
              🔄 Repetir búsqueda
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="state-box">
        <p>No hay búsquedas registradas</p>
        <router-link to="/search" class="btn btn-primary">Realizar primera búsqueda</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useSearchStore } from '../stores/searchStore'
import { useRouter } from 'vue-router'

const searchStore = useSearchStore()
const router = useRouter()

const loading = computed(() => {
  // Simulate loading if needed
  return false
})
const searchHistory = computed(() => searchStore.searchHistory)

onMounted(async () => {
  await searchStore.loadSearchHistory()
})

function getSearchTitle(search: any): string {
  const parts = []
  if (search.tipo_negocio) parts.push(search.tipo_negocio)
  if (search.zona) parts.push(`en ${search.zona}`)
  return parts.length > 0 ? parts.join(' ') : 'Búsqueda'
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  const today = new Date()
  const diffTime = today.getTime() - date.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays === 0) {
    const diffHours = Math.floor(diffTime / (1000 * 60 * 60))
    if (diffHours === 0) return 'Hace poco'
    return `Hace ${diffHours}h`
  }
  if (diffDays === 1) return 'Ayer'
  if (diffDays < 7) return `Hace ${diffDays} días`

  return date.toLocaleDateString('es-EC', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

async function replaySearch(searchId: string) {
  await searchStore.replaySearch(searchId)
  router.push('/search')
}
</script>

<style scoped>
.state-box {
  padding: 48px 24px;
  text-align: center;
  background: var(--ink-2);
  border-radius: 10px;
  border: 1px solid var(--line);
  color: var(--text-muted);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var(--line);
  border-top-color: var(--orange);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.history-list {
  display: grid;
  gap: 12px;
}

.history-card {
  background: var(--ink-2);
  border: 1px solid var(--line);
  border-radius: 8px;
  overflow: hidden;
  transition: all 200ms ease-out;
}

.history-card:hover {
  border-color: var(--orange);
  box-shadow: 0 4px 12px rgba(255, 159, 67, 0.1);
}

.card-header {
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.search-info {
  flex: 1;
}

.search-title {
  margin: 0 0 4px;
  font-size: 15px;
  font-weight: 600;
  color: var(--text);
}

.search-meta {
  margin: 0;
  font-size: 12px;
  color: var(--text-muted);
}

.search-date {
  font-size: 12px;
  color: var(--text-muted);
  white-space: nowrap;
  text-align: right;
}

.card-footer {
  padding: 12px 16px;
  background: var(--ink-1);
  border-top: 1px solid var(--line);
  display: flex;
  gap: 8px;
}

.btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 150ms;
}

.btn-sm {
  padding: 6px 12px;
}

.btn-primary {
  background: var(--orange);
  color: var(--ink-1);
}

.btn-primary:hover {
  background: #ff6b35;
  transform: scale(1.05);
}
</style>
