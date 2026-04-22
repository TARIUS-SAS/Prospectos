<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Búsqueda / Nueva</p>
        <h1>Nueva búsqueda avanzada</h1>
      </div>
    </div>

    <div class="page-main">
      <div class="search-form-panel">
        <form @submit.prevent="handleSearch">
          <div style="margin-bottom: 16px;">
            <label style="font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.1em; font-weight: 600;">
              Filtros (mínimo 1)
            </label>
          </div>

          <!-- Dynamic filters -->
          <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px;">
            <FilterRow
              v-for="(filter, idx) in filterStore.filters"
              :key="filter.id"
              :field="filter.field"
              :value="filter.value"
              :canRemove="filterStore.filters.length > 1"
              @update:field="(f) => filterStore.updateFilter(filter.id, filterStore.filters.find(x => x.id === filter.id)?.value || '')"
              @update:value="(v) => filterStore.updateFilter(filter.id, v)"
              @remove="filterStore.removeFilter(filter.id)"
            />
          </div>

          <!-- Add filter button -->
          <button
            v-if="filterStore.filters.length > 0"
            type="button"
            @click="addNewFilter"
            class="btn btn-secondary"
            style="margin-bottom: 20px; width: 100%;"
          >
            + Agregar filtro
          </button>

          <!-- Cost estimate -->
          <div v-if="filterStore.isValidToSearch" style="padding: 16px 20px; background: linear-gradient(135deg, var(--orange-glow), transparent); border: 1px solid var(--orange-line); border-radius: 10px; display: flex; align-items: center; margin-bottom: 20px;">
            <div>
              <div style="font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; margin-bottom: 8px;">💰 Costo estimado</div>
              <div style="display: flex; align-items: baseline; gap: 8px;">
                <div style="font-size: 24px; font-weight: 700; color: var(--orange);">${{ estimatedCost.toFixed(2) }}</div>
                <div style="font-size: 11px; color: var(--text-muted);">{{ filterStore.filterCount }} filtros × {{ cantidadResultados }} empresas</div>
              </div>
            </div>
          </div>

          <div style="display: grid; grid-template-columns: 1.2fr 1fr; gap: 12px; margin-bottom: 16px;">
            <div class="field">
              <label>Cantidad de resultados</label>
              <input v-model.number="cantidadResultados" type="number" min="1" max="100" class="input">
            </div>
            <button
              type="submit"
              class="btn btn-primary btn-lg"
              style="align-self: flex-end; width: 100%;"
              :disabled="isLoading || !filterStore.isValidToSearch"
            >
              {{ isLoading ? 'Buscando...' : '🔍 Buscar' }}
            </button>
          </div>

          <button type="button" @click="limpiarFiltros" class="btn btn-secondary btn-lg btn-block">
            Limpiar filtros
          </button>
        </form>
      </div>

      <!-- Loading state -->
      <div v-if="isLoading" style="text-align: center; padding: 48px 24px;">
        <div style="width: 48px; height: 48px; border: 4px solid var(--orange); border-top-color: transparent; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px;"></div>
        <div style="color: var(--text-muted);">Buscando... <span style="color: var(--orange); font-weight: 600;">{{ resultados.length }}</span> encontrados</div>
      </div>

      <!-- Results -->
      <div v-else-if="resultados.length > 0">
        <div style="color: var(--text-muted); font-size: 12px; margin-bottom: 12px;">{{ resultados.length }} resultados encontrados</div>
        <router-link
          v-for="prospect in resultados"
          :key="prospect.id"
          :to="{ name: 'ProspectDetail', params: { id: prospect.id } }"
          class="prospect-card"
        >
          <div>
            <div style="font-weight: 600; color: var(--text); margin-bottom: 4px;">{{ prospect.nombre }}</div>
            <div style="font-size: 13px; color: var(--text-muted); margin-bottom: 8px;">{{ prospect.dirección }}</div>
            <a :href="`tel:${prospect.teléfono}`" style="font-size: 13px; color: var(--orange);" @click.stop>
              📞 {{ prospect.teléfono }}
            </a>
          </div>
          <div style="text-align: right;">
            <div :style="['font-size: 24px; font-weight: 700', prospect.es_caliente ? 'color: var(--orange)' : 'color: var(--text-muted)']">
              {{ prospect.score }}
            </div>
            <div v-if="prospect.es_caliente" style="font-size: 11px; color: var(--orange); font-weight: 600;">🔥 CALIENTE</div>
          </div>
        </router-link>
      </div>

      <!-- Error state -->
      <div v-else-if="errorSearch" style="text-align: center; padding: 48px 24px;">
        <div style="color: var(--error); font-size: 16px; font-weight: 600; margin-bottom: 8px;">⚠️ Error en búsqueda</div>
        <div style="color: var(--text-muted);">{{ errorSearch }}</div>
      </div>

      <!-- Empty state -->
      <div v-else style="text-align: center; padding: 48px 24px;">
        <div style="color: var(--text-muted); margin-bottom: 12px;">Agrega al menos un filtro para comenzar</div>
        <button type="button" @click="addNewFilter" class="btn btn-primary btn-sm">
          + Agregar primer filtro
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useFilterStore } from '../stores/filterStore'
import { useCostStore } from '../stores/costStore'
import { useSupabase } from '../composables/useSupabase'
import FilterRow from '../components/FilterRow.vue'

const filterStore = useFilterStore()
const costStore = useCostStore()
const supabase = useSupabase()

const cantidadResultados = ref(20)
const resultados = ref<any[]>([])
const isLoading = ref(false)
const errorSearch = ref('')

const estimatedCost = computed(() => {
  if (!filterStore.isValidToSearch) return 0
  return costStore.costPerSearch * cantidadResultados.value * filterStore.filterCount
})

function addNewFilter() {
  filterStore.addFilter('zona', '')
}

async function handleSearch() {
  if (!filterStore.isValidToSearch) return

  isLoading.value = true
  errorSearch.value = ''

  try {
    const filtersRequest = filterStore.getFiltersForRequest()
    const token = (await supabase.client.auth.getSession()).data.session?.access_token
    if (!token) {
      throw new Error('No autenticado')
    }

    const response = await supabase.callEdgeFunction('search-google-places', {
      query: filtersRequest.nombre || `${filtersRequest.tipo_negocio || 'negocios'} ${filtersRequest.zona}`,
      zona: filtersRequest.zona || null,
      tipo_negocio: filtersRequest.tipo_negocio || null,
      nombre: filtersRequest.nombre || null,
      empleados_range: filtersRequest.empleados_range || null,
      presencia_web: filtersRequest.presencia_web || null,
      cantidad_resultados: cantidadResultados.value,
    })

    if (response?.resultados) {
      resultados.value = response.resultados.map((p: any) => ({
        ...p,
        es_caliente: p.es_caliente || false,
      }))
    }
  } catch (err: any) {
    errorSearch.value = err.message || 'Error en la búsqueda'
  } finally {
    isLoading.value = false
  }
}

function limpiarFiltros() {
  filterStore.clearFilters()
  resultados.value = []
  errorSearch.value = ''
  addNewFilter()
}
</script>

<style scoped>
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.prospect-card {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 20px;
  background: var(--ink-2);
  border: 1px solid var(--line-soft);
  border-radius: 10px;
  margin-bottom: 12px;
  transition: all 180ms ease-out;
}

.prospect-card:hover {
  border-color: var(--orange);
}
</style>
