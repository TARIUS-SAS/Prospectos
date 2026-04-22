<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Operación / Hoy</p>
        <h1>Dashboard</h1>
      </div>
      <div class="page-head-right">
        <div class="page-head-time">{{ currentTime }}</div>
        <div class="page-head-city">QUITO</div>
      </div>
    </div>

    <div class="page-main">
      <!-- Stats Grid -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="label"><span class="dot"></span>Total búsquedas</div>
          <div class="value">{{ stats.totalSearches }}</div>
          <div class="trend">Hoy</div>
        </div>
        <div class="stat-card">
          <div class="label"><span class="dot"></span>Total empresas</div>
          <div class="value">{{ stats.totalCompanies }}</div>
          <div class="trend">encontradas</div>
        </div>
        <div class="stat-card spark">
          <div class="label"><span class="dot"></span>Costo hoy</div>
          <div class="value">${{ stats.dailyCost.toFixed(2) }}</div>
          <div class="trend">USD</div>
        </div>
        <div class="stat-card spark">
          <div class="label"><span class="dot"></span>Costo mes</div>
          <div class="value">${{ stats.monthlyCost.toFixed(2) }}</div>
          <div class="trend">USD</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useCostStore } from '../stores/costStore'
import { useSupabase } from '../composables/useSupabase'

const authStore = useAuthStore()
const costStore = useCostStore()
const supabase = useSupabase()

const currentTime = ref('')

const stats = ref({
  totalSearches: 0,
  totalCompanies: 0,
  savedProspects: 0,
  commitments: 0,
  dailyCost: 0,
  monthlyCost: 0,
})


onMounted(() => {
  // Update time every second
  const updateTime = () => {
    const now = new Date()
    currentTime.value = now.toLocaleTimeString('es-EC', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
    })
  }
  updateTime()
  setInterval(updateTime, 1000)

  // Load stats
  loadStats()
})

async function loadStats() {
  if (!authStore.user?.id) return

  try {
    const today = new Date().toISOString().split('T')[0]
    const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1)
      .toISOString()
      .split('T')[0]

    // Get search stats
    const { data: searchData } = await supabase.client
      .from('searches')
      .select('*')
      .eq('usuario_id', authStore.user.id)
      .gte('created_at', today)

    const { data: monthData } = await supabase.client
      .from('searches')
      .select('*')
      .eq('usuario_id', authStore.user.id)
      .gte('created_at', monthStart)

    // Get saved prospects
    const { data: savedData } = await supabase.client
      .from('saved_prospects')
      .select('id')
      .eq('usuario_id', authStore.user.id)

    stats.value.totalSearches = searchData?.length || 0
    stats.value.totalCompanies = searchData?.reduce((sum, s: any) => sum + (s.cantidad_resultados || 0), 0) || 0
    stats.value.savedProspects = savedData?.length || 0
    stats.value.dailyCost = searchData?.reduce((sum, s: any) => sum + (s.costo_total_venta || 0), 0) || 0
    stats.value.monthlyCost = monthData?.reduce((sum, s: any) => sum + (s.costo_total_venta || 0), 0) || 0
  } catch (error) {
    console.error('Error loading stats:', error)
  }
}
</script>

<style scoped>
.page-head-time {
  font-size: 18px;
  font-weight: 700;
  color: var(--orange);
  font-family: var(--font-mono);
  margin-bottom: 4px;
}

.page-head-city {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border: 1px solid var(--line);
  border-radius: 999px;
  font-size: 10px;
  letter-spacing: 0.1em;
}

.page-head-city::before {
  content: "";
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--orange);
}

.icon {
  color: var(--text-muted);
}

.tanda-item.active .icon {
  color: var(--orange);
}
</style>
