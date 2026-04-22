<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Administración</p>
        <h1>Admin Panel</h1>
      </div>
    </div>

    <div class="page-main">
      <!-- Stats -->
      <div class="stats-grid" style="margin-bottom: 28px;">
        <div class="stat-card">
          <div class="label"><span class="dot"></span>Costo real</div>
          <div class="value">${{ adminStats.costReal.toFixed(2) }}</div>
          <div class="trend">mes</div>
        </div>
        <div class="stat-card">
          <div class="label"><span class="dot"></span>Ingresos</div>
          <div class="value">${{ adminStats.ingresos.toFixed(2) }}</div>
          <div class="trend">mes</div>
        </div>
        <div class="stat-card">
          <div class="label"><span class="dot"></span>Margen</div>
          <div class="value">{{ adminStats.margen }}%</div>
          <div class="trend">neto</div>
        </div>
      </div>

      <!-- Tabs -->
      <div style="display: flex; gap: 12px; margin-bottom: 20px; border-bottom: 1px solid var(--line-soft); padding-bottom: 12px;">
        <button
          v-for="tab in ['Usuarios', 'Facturación', 'Configuración']"
          :key="tab"
          @click="activeTab = tab"
          :class="['btn', 'btn-sm', activeTab === tab ? 'btn-primary' : 'btn-ghost']"
        >
          {{ tab }}
        </button>
      </div>

      <!-- Tab: Usuarios -->
      <div v-if="activeTab === 'Usuarios'" class="panel">
        <div class="panel-head">
          <h3>Usuarios registrados</h3>
          <span class="right">{{ users.length }} total</span>
        </div>
        <div v-if="users.length > 0" style="display: grid; gap: 8px;">
          <div
            v-for="user in users"
            :key="user.id"
            style="display: flex; justify-content: space-between; align-items: center; padding: 12px; background: var(--ink-1); border-radius: 8px; border: 1px solid var(--line-soft);"
          >
            <div>
              <div style="font-weight: 600; color: var(--text);">{{ user.email }}</div>
              <div style="font-size: 12px; color: var(--text-muted);">Plan: <strong>{{ user.plan }}</strong> | Creado: {{ formatDate(user.created_at) }}</div>
            </div>
            <div style="text-align: right; font-size: 12px;">
              <div style="color: var(--orange); font-weight: 600;">{{ user.uso }} búsquedas</div>
              <div style="color: var(--text-muted);">${{ user.costo.toFixed(2) }} gastado</div>
            </div>
          </div>
        </div>
        <div v-else style="padding: 32px; text-align: center; color: var(--text-muted);">
          Sin usuarios
        </div>
      </div>

      <!-- Tab: Facturación -->
      <div v-else-if="activeTab === 'Facturación'" class="panel">
        <div class="panel-head">
          <h3>Facturación</h3>
        </div>
        <div style="padding: 32px; text-align: center; color: var(--text-muted);">
          ⚙️ Módulo en desarrollo
        </div>
      </div>

      <!-- Tab: Configuración -->
      <div v-else-if="activeTab === 'Configuración'" class="panel">
        <div class="panel-head">
          <h3>Costos operacionales</h3>
        </div>
        <div style="display: grid; gap: 16px;">
          <div class="field">
            <label>Costo por búsqueda (USD)</label>
            <input
              type="number"
              v-model.number="config.costPerSearch"
              class="input"
              step="0.01"
            >
            <div class="helper">Costo base a Google Places API</div>
          </div>
          <div class="field">
            <label>Costo por actualización (USD)</label>
            <input
              type="number"
              v-model.number="config.costPerUpdate"
              class="input"
              step="0.01"
            >
            <div class="helper">Costo para actualizar datos de prospecto</div>
          </div>
          <div class="field">
            <label>Margen mínimo esperado (%)</label>
            <input
              type="number"
              v-model.number="config.minMargin"
              class="input"
              step="1"
              min="0"
              max="100"
            >
          </div>
          <button class="btn btn-primary" @click="saveConfig" :disabled="isSavingConfig">
            {{ isSavingConfig ? 'Guardando...' : 'Guardar configuración' }}
          </button>
        </div>
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

const activeTab = ref('Usuarios')
const isSavingConfig = ref(false)

const adminStats = ref({
  costReal: 234.56,
  ingresos: 1200.00,
  margen: 81,
})

const users = ref<any[]>([])

const config = ref({
  costPerSearch: 0.05,
  costPerUpdate: 0.10,
  minMargin: 70,
})

onMounted(() => {
  loadUsers()
  loadConfig()
})

async function loadUsers() {
  try {
    // Get all users with their usage stats
    const { data: usersData, error: usersError } = await supabase.client
      .from('users_metadata')
      .select(`
        usuario_id,
        auth_user:auth.users(email, created_at),
        plan_name
      `)
      .limit(100)

    if (usersError) throw usersError

    // Get stats for each user
    const usersWithStats = await Promise.all(
      (usersData || []).map(async (u: any) => {
        const { data: searches } = await supabase.client
          .from('searches')
          .select('costo_total_venta')
          .eq('usuario_id', u.usuario_id)

        const costo = searches?.reduce((sum, s: any) => sum + (s.costo_total_venta || 0), 0) || 0

        return {
          id: u.usuario_id,
          email: u.auth_user?.email || 'Usuario',
          plan: u.plan_name || 'Starter',
          uso: searches?.length || 0,
          costo,
          created_at: u.auth_user?.created_at,
        }
      })
    )

    users.value = usersWithStats
  } catch (error) {
    console.error('Error loading users:', error)
  }
}

async function loadConfig() {
  try {
    const { data, error } = await supabase.client
      .from('users_metadata')
      .select('admin_config')
      .eq('usuario_id', authStore.user?.id)
      .single()

    if (error && error.code !== 'PGRST116') throw error
    if (data?.admin_config) {
      config.value = data.admin_config
    }
  } catch (error) {
    console.error('Error loading config:', error)
  }
}

async function saveConfig() {
  if (!authStore.user?.id) return

  isSavingConfig.value = true
  try {
    const { error } = await supabase.client
      .from('users_metadata')
      .upsert({
        usuario_id: authStore.user.id,
        admin_config: config.value,
        updated_at: new Date().toISOString(),
      })

    if (error) throw error
    alert('Configuración guardada')
  } catch (error) {
    console.error('Error saving config:', error)
    alert('Error al guardar configuración')
  } finally {
    isSavingConfig.value = false
  }
}

function formatDate(dateString: string) {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('es-EC')
}
</script>
