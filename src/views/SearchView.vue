<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Búsqueda</p>
        <h1>Buscar Prospects</h1>
      </div>
    </div>

    <div class="page-main">
      <div class="search-grid">
        <!-- LEFT: Filters -->
        <div class="filters-panel">
          <h3>Filtros</h3>

          <div class="filter-group">
            <label>Zona (Quito)</label>
            <select v-model="searchStore.filters.zona" class="input">
              <option value="">Todas</option>
              <option value="Centro">Centro</option>
              <option value="Cumbayá">Cumbayá</option>
              <option value="La Carolina">La Carolina</option>
              <option value="Quito Norte">Quito Norte</option>
              <option value="Quito Sur">Quito Sur</option>
              <option value="Calderón">Calderón</option>
            </select>
          </div>

          <div class="filter-group">
            <label>Tipo de Negocio</label>
            <input
              v-model="searchStore.filters.tipo_negocio"
              type="text"
              placeholder="Café, Farmacia, Ferretería..."
              class="input"
            >
          </div>

          <div class="filter-group">
            <label>Palabra Clave</label>
            <input
              v-model="searchStore.filters.palabra_clave"
              type="text"
              placeholder="(Opcional)"
              class="input"
            >
          </div>

          <div class="filter-group">
            <label>Empleados</label>
            <select v-model="searchStore.filters.empleados_range" class="input">
              <option value="">Cualquiera</option>
              <option value="1-5">1-5</option>
              <option value="5-20">5-20</option>
              <option value="20-50">20-50</option>
              <option value="50+">50+</option>
            </select>
          </div>

          <div class="filter-group">
            <label>Presencia Web</label>
            <select v-model="searchStore.filters.presencia_web" class="input">
              <option value="">Cualquiera</option>
              <option value="sin_web">Sin website</option>
              <option value="redes">Solo redes</option>
              <option value="website">Website HTTPS</option>
            </select>
          </div>

          <div class="filter-group">
            <label>
              <input type="checkbox" v-model="searchStore.filters.sri_activo">
              Solo SRI Activos
            </label>
          </div>

          <div class="filter-group">
            <label>Cantidad de Resultados</label>
            <input
              v-model.number="searchStore.filters.cantidad_resultados"
              type="number"
              min="1"
              max="100"
              placeholder="20"
              class="input"
            >
            <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
              Mínimo: 1, Máximo: 100
            </div>
          </div>

          <button
            @click="searchStore.performSearch()"
            :disabled="searchStore.loading"
            class="btn btn-primary btn-lg"
            style="width: 100%; margin-bottom: 8px;"
          >
            {{ searchStore.loading ? '⏳ Buscando...' : '🔍 Buscar' }}
          </button>

          <button
            @click="searchStore.clearFilters()"
            class="btn btn-secondary btn-lg"
            style="width: 100%;"
          >
            Limpiar
          </button>
        </div>

        <!-- RIGHT: Results -->
        <div class="results-panel">
          <div v-if="searchStore.loading" class="state-box">
            <div class="spinner"></div>
            <p>Buscando prospects...</p>
            <p style="font-size: 12px; color: var(--orange);">{{ searchStore.resultCount }} encontrados</p>
          </div>

          <div v-else-if="searchStore.error" class="state-box error">
            <p>❌ {{ searchStore.error }}</p>
          </div>

          <div v-else-if="searchStore.resultCount > 0" class="results">
            <div class="results-header">
              <div>
                <h3>{{ searchStore.resultCount }} Prospects</h3>
                <p style="font-size: 12px; color: var(--text-muted);">{{ searchStore.hotProspects.length }} calientes 🔥</p>
              </div>
              <button @click="searchStore.exportCSV()" class="btn btn-sm">📥 CSV</button>
            </div>

            <div class="prospects-list">
              <ProspectCard
                v-for="prospect in searchStore.results"
                :key="prospect.id"
                :prospect="prospect"
                @save="saveProspect(prospect)"
              />
            </div>
          </div>

          <div v-else class="state-box">
            <p>Sin resultados. Intenta otra búsqueda.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useSearchStore } from '../stores/searchStore'
import { useSavedStore } from '../stores/savedStore'
import { useRouter } from 'vue-router'
import ProspectCard from '../components/ProspectCard.vue'

const searchStore = useSearchStore()
const savedStore = useSavedStore()
const router = useRouter()

async function saveProspect(prospect: any) {
  await savedStore.saveProspect(prospect)
  // Mostrar toast (tu UI debe tener esto)
  alert(`✅ ${prospect.nombre} guardado`)
}
</script>

<style scoped>
.search-grid {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 24px;
  margin-top: 24px;
}

.filters-panel {
  background: var(--ink-2);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid var(--line);
  height: fit-content;
  position: sticky;
  top: 20px;
}

.filters-panel h3 {
  font-size: 16px;
  margin-bottom: 16px;
  color: var(--text);
}

.filter-group {
  margin-bottom: 16px;
}

.filter-group label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.filter-group input[type="checkbox"] {
  margin-right: 6px;
}

.input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid var(--line);
  border-radius: 6px;
  background: var(--ink-1);
  color: var(--text);
  font-size: 14px;
}

.input:focus {
  outline: none;
  border-color: var(--orange);
  box-shadow: 0 0 0 2px rgba(255, 159, 67, 0.1);
}

.results-panel {
  background: var(--ink-2);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid var(--line);
}

.state-box {
  padding: 48px 24px;
  text-align: center;
  color: var(--text-muted);
}

.state-box.error {
  color: var(--error);
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

.results-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--line);
}

.results-header h3 {
  font-size: 18px;
  margin-bottom: 4px;
}

.prospects-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

@media (max-width: 1024px) {
  .search-grid {
    grid-template-columns: 1fr;
  }

  .filters-panel {
    position: relative;
    top: 0;
  }
}
</style>
