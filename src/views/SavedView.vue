<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Guardados</p>
        <h1>Prospectos guardados</h1>
      </div>
    </div>

    <div class="page-main">
      <div style="margin-bottom: 20px; display: flex; gap: 12px; align-items: center;">
        <div>
          <label style="font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.1em; font-weight: 600; display: block; margin-bottom: 8px;">Filtrar por estado</label>
          <select v-model="filterStatus" class="select" style="max-width: 240px;">
            <option value="">Todos ({{ filteredProspects.length }})</option>
            <option value="nuevo">Nuevo</option>
            <option value="contactado">Contactado</option>
            <option value="interesado">Interesado</option>
            <option value="rechazado">Rechazado</option>
          </select>
        </div>
      </div>

      <div v-if="isLoading" style="text-align: center; padding: 48px 24px;">
        <div style="width: 48px; height: 48px; border: 4px solid var(--orange); border-top-color: transparent; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px;"></div>
        <div style="color: var(--text-muted);">Cargando prospectos...</div>
      </div>

      <div v-else-if="filteredProspects.length > 0" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px;">
        <router-link
          v-for="prospect in filteredProspects"
          :key="prospect.id"
          :to="{ name: 'ProspectDetail', params: { id: prospect.id } }"
          class="prospect-card"
        >
          <div style="font-weight: 600; color: var(--text); margin-bottom: 8px;">{{ prospect.nombre }}</div>
          <div style="font-size: 13px; color: var(--text-muted); margin-bottom: 8px;">{{ prospect.direccion }}</div>
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div :style="['font-weight: 700; font-size: 18px;', prospect.score >= 15 ? 'color: var(--orange)' : 'color: var(--text-muted)']">
              {{ prospect.score }}
            </div>
            <span v-if="prospect.estado" style="font-size: 10px; padding: 4px 8px; background: var(--orange-glow); color: var(--orange); border-radius: 4px; font-weight: 600; text-transform: uppercase;">
              {{ prospect.estado }}
            </span>
          </div>
          <div v-if="prospect.notas" style="font-size: 12px; color: var(--text-muted); padding-top: 8px; border-top: 1px solid var(--line-soft);">
            {{ prospect.notas.substring(0, 60) }}{{ prospect.notas.length > 60 ? '...' : '' }}
          </div>
        </router-link>
      </div>

      <div v-else style="text-align: center; padding: 48px 24px;">
        <div style="color: var(--text-muted); margin-bottom: 12px;">💾 No hay prospectos guardados</div>
        <router-link to="/search" class="btn btn-primary btn-sm">
          Realizar búsqueda
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/authStore'
import { useSupabase } from '../composables/useSupabase'

const authStore = useAuthStore()
const supabase = useSupabase()

const filterStatus = ref('')
const savedProspects = ref<any[]>([])
const isLoading = ref(false)

const filteredProspects = computed(() => {
  if (!filterStatus.value) return savedProspects.value
  return savedProspects.value.filter(p => p.estado === filterStatus.value)
})

onMounted(() => {
  loadSavedProspects()
})

async function loadSavedProspects() {
  if (!authStore.user?.id) return

  isLoading.value = true
  try {
    const { data, error } = await supabase.client
      .from('saved_prospects')
      .select(`
        id,
        prospect_id,
        estado,
        notas,
        prospects (
          id,
          nombre,
          direccion,
          score,
          es_caliente
        )
      `)
      .eq('usuario_id', authStore.user.id)
      .order('created_at', { ascending: false })

    if (error) throw error

    savedProspects.value = (data || []).map((sp: any) => ({
      id: sp.prospect_id,
      ...sp.prospects,
      estado: sp.estado,
      notas: sp.notas,
    }))
  } catch (error) {
    console.error('Error loading saved prospects:', error)
  } finally {
    isLoading.value = false
  }
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

.prospect-card {
  padding: 16px;
  background: var(--ink-2);
  border: 1px solid var(--line-soft);
  border-radius: 10px;
  transition: all 180ms ease-out;
  display: block;
}

.prospect-card:hover {
  border-color: var(--orange);
  box-shadow: 0 0 0 3px var(--orange-glow);
}
</style>
