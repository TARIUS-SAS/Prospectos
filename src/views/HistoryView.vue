<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Historial</p>
        <h1>Mis búsquedas</h1>
      </div>
    </div>

    <div class="page-main">
      <div v-if="isLoading" style="text-align: center; padding: 48px 24px;">
        <div style="width: 48px; height: 48px; border: 4px solid var(--orange); border-top-color: transparent; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px;"></div>
        <div style="color: var(--text-muted);">Cargando búsquedas...</div>
      </div>

      <div v-else-if="searches.length > 0" style="display: grid; gap: 12px;">
        <div v-for="search in searches" :key="search.id" class="panel">
          <div style="display: flex; justify-content: space-between; align-items: start; gap: 16px;">
            <div style="flex: 1;">
              <div style="font-weight: 600; color: var(--text); margin-bottom: 4px;">
                {{ search.query || `${search.tipo_negocio || 'Búsqueda'} - ${search.zona || 'General'}` }}
              </div>
              <div style="font-size: 13px; color: var(--text-muted);">
                {{ search.cantidad_resultados || 0 }} resultados encontrados
              </div>
            </div>
            <div style="text-align: right;">
              <div style="font-weight: 600; color: var(--orange);">${{ (search.costo_total_venta || 0).toFixed(2) }}</div>
              <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">{{ formatDate(search.created_at) }}</div>
            </div>
            <router-link
              :to="{ name: 'Search', query: { from: 'history', id: search.id } }"
              class="btn btn-sm btn-secondary"
            >
              Ver resultados
            </router-link>
          </div>
        </div>
      </div>

      <div v-else style="text-align: center; padding: 48px 24px;">
        <div style="color: var(--text-muted); margin-bottom: 12px;">📭 No hay búsquedas registradas</div>
        <router-link to="/search" class="btn btn-primary btn-sm">
          Realizar primera búsqueda
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useSupabase } from '../composables/useSupabase'

const authStore = useAuthStore()
const supabase = useSupabase()

const searches = ref<any[]>([])
const isLoading = ref(false)

onMounted(() => {
  loadSearchHistory()
})

async function loadSearchHistory() {
  if (!authStore.user?.id) return

  isLoading.value = true
  try {
    const { data, error } = await supabase.client
      .from('searches')
      .select('*')
      .eq('usuario_id', authStore.user.id)
      .order('created_at', { ascending: false })
      .limit(50)

    if (error) throw error
    searches.value = data || []
  } catch (error) {
    console.error('Error loading search history:', error)
  } finally {
    isLoading.value = false
  }
}

function formatDate(dateString: string) {
  const date = new Date(dateString)
  return date.toLocaleDateString('es-EC', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<style scoped>
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
