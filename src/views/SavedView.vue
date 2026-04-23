<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>CRM</p>
        <h1>Prospectos Guardados</h1>
      </div>
    </div>

    <div class="page-main">
      <!-- Filter Bar -->
      <div class="filter-bar">
        <div class="filter-group">
          <label>Estado</label>
          <select v-model="filterEstadoLocal" class="input">
            <option value="">Todos ({{ filteredSaved.length }})</option>
            <option value="Nuevo">Nuevo</option>
            <option value="Contactado">Contactado</option>
            <option value="Interesado">Interesado</option>
            <option value="Ganado">Ganado</option>
          </select>
        </div>
        <button @click="sortByAction" class="btn btn-secondary">
          {{ sortMode === 'action' ? 'Por acción' : 'Por creación' }}
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="state-box">
        <div class="spinner"></div>
        <p>Cargando prospectos...</p>
      </div>

      <!-- Results Table -->
      <div v-else-if="filteredSaved.length > 0" class="table-container">
        <table class="prospects-table">
          <thead>
            <tr>
              <th>Prospect</th>
              <th>Ubicación</th>
              <th>Score</th>
              <th>Estado</th>
              <th>Próxima acción</th>
              <th>Notas</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="saved in filteredSaved" :key="saved.id" class="table-row">
              <td class="cell-name">
                <div class="prospect-name">{{ saved.prospect?.nombre }}</div>
              </td>
              <td class="cell-location">{{ saved.prospect?.direccion }}</td>
              <td class="cell-score">
                <span :class="['score-badge', scoreClass(saved.prospect?.score)]">
                  {{ saved.prospect?.score }}
                </span>
              </td>
              <td class="cell-estado">
                <span :class="['status-badge', saved.estado.toLowerCase()]">
                  {{ saved.estado }}
                </span>
              </td>
              <td class="cell-action">
                {{ formatDateShort(saved.proxima_accion) }}
              </td>
              <td class="cell-notes">{{ saved.notas?.substring(0, 40) || '—' }}</td>
              <td class="cell-actions">
                <button @click="editProspect(saved)" class="btn-icon" title="Editar">Ed.</button>
                <button @click="deleteProspect(saved.id)" class="btn-icon" title="Eliminar">Del</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-else class="state-box">
        <p>No hay prospectos guardados aún</p>
        <router-link to="/search" class="btn btn-primary">Ir a búsqueda</router-link>
      </div>

      <!-- Edit Modal -->
      <div v-if="editingId" class="modal-overlay" @click="closeEdit">
        <div class="modal" @click.stop>
          <h3>Editar prospect</h3>
          <div class="form-group">
            <label>Estado</label>
            <select v-model="editForm.estado" class="input">
              <option value="Nuevo">Nuevo</option>
              <option value="Contactado">Contactado</option>
              <option value="Interesado">Interesado</option>
              <option value="Ganado">Ganado</option>
            </select>
          </div>
          <div class="form-group">
            <label>Notas</label>
            <textarea v-model="editForm.notas" class="input textarea" rows="4"></textarea>
          </div>
          <div class="form-group">
            <label>Próxima acción</label>
            <input v-model="editForm.proxima_accion" type="date" class="input">
          </div>
          <div class="modal-buttons">
            <button @click="closeEdit" class="btn btn-secondary">Cancelar</button>
            <button @click="saveEdit" class="btn btn-primary">Guardar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useSavedStore } from '../stores/savedStore'

const savedStore = useSavedStore()
const filterEstado = ref('')
const sortMode = ref<'action' | 'created'>('action')
const editingId = ref<string | null>(null)
const editForm = ref({ estado: '', notas: '', proxima_accion: '' })

const loading = computed(() => savedStore.loading)
const filteredSaved = computed(() => {
  let filtered = savedStore.filteredSaved
  if (sortMode.value === 'action') {
    filtered = [...filtered].sort((a: any, b: any) => {
      const aDate = a.proxima_accion ? new Date(a.proxima_accion) : new Date(9999, 0, 0)
      const bDate = b.proxima_accion ? new Date(b.proxima_accion) : new Date(9999, 0, 0)
      return aDate.getTime() - bDate.getTime()
    })
  }
  return filtered
})

// Computed filter binding
const filterEstadoLocal = computed({
  get: () => filterEstado.value,
  set: (value) => {
    filterEstado.value = value
    savedStore.filterEstado = value || 'Todos'
  }
})

onMounted(async () => {
  await savedStore.loadSaved()
})

function scoreClass(score: number): string {
  if (score >= 70) return 'hot'
  if (score >= 50) return 'warm'
  return 'cold'
}

function formatDateShort(date: string | null): string {
  if (!date) return '—'
  const d = new Date(date)
  const today = new Date()
  const diffTime = today.getTime() - d.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays < 0) return `En ${Math.abs(diffDays)}d`
  if (diffDays === 0) return 'Hoy'
  if (diffDays === 1) return 'Ayer'
  return d.toLocaleDateString('es-EC', { month: 'short', day: 'numeric' })
}

function sortByAction() {
  sortMode.value = sortMode.value === 'action' ? 'created' : 'action'
}

function editProspect(saved: any) {
  editingId.value = saved.id
  editForm.value = {
    estado: saved.estado,
    notas: saved.notas || '',
    proxima_accion: saved.proxima_accion || ''
  }
}

function closeEdit() {
  editingId.value = null
}

async function saveEdit() {
  if (!editingId.value) return

  const validEstados = ['Nuevo', 'Contactado', 'Interesado', 'Ganado']
  if (!validEstados.includes(editForm.value.estado)) {
    alert('Estado inválido')
    return
  }

  await savedStore.updateProspectStatus(
    editingId.value,
    editForm.value.estado,
    editForm.value.notas,
    editForm.value.proxima_accion
  )
  closeEdit()
}

async function deleteProspect(savedId: string) {
  if (confirm('¿Eliminar este prospect?')) {
    await savedStore.deleteProspect(savedId)
  }
}
</script>

<style scoped>
.filter-bar {
  display: flex;
  gap: 16px;
  align-items: flex-end;
  margin-bottom: 24px;
  background: var(--ink-2);
  padding: 16px;
  border-radius: 8px;
  border: 1px solid var(--line);
}

.filter-group {
  flex: 1;
  min-width: 200px;
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

.textarea {
  resize: vertical;
}

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

.table-container {
  background: var(--ink-2);
  border-radius: 10px;
  border: 1px solid var(--line);
  overflow-x: auto;
}

.prospects-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.prospects-table thead {
  background: var(--ink-1);
  border-bottom: 2px solid var(--line);
}

.prospects-table th {
  padding: 12px 16px;
  text-align: left;
  font-weight: 600;
  color: var(--text-muted);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.prospects-table tbody tr {
  border-bottom: 1px solid var(--line);
  transition: background 150ms;
}

.prospects-table tbody tr:hover {
  background: rgba(255, 159, 67, 0.03);
}

.prospects-table td {
  padding: 12px 16px;
  color: var(--text);
}

.cell-name {
  font-weight: 600;
  color: var(--text);
}

.prospect-name {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cell-location {
  color: var(--text-muted);
  font-size: 13px;
  max-width: 150px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cell-score {
  text-align: center;
}

.score-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 600;
  font-size: 13px;
}

.score-badge.hot {
  background: linear-gradient(135deg, var(--orange), #ff6b35);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.score-badge.warm {
  color: #f59e0b;
}

.score-badge.cold {
  color: var(--text-muted);
}

.cell-estado {
  text-align: center;
}

.status-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 11px;
  font-weight: 600;
}

.status-badge.nuevo {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.status-badge.contactado {
  background: rgba(245, 158, 11, 0.2);
  color: #f59e0b;
}

.status-badge.interesado {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.status-badge.ganado {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.cell-action {
  font-size: 12px;
  color: var(--text-muted);
}

.cell-notes {
  font-size: 12px;
  color: var(--text-muted);
  max-width: 150px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cell-actions {
  display: flex;
  gap: 6px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px;
  transition: transform 150ms;
}

.btn-icon:hover {
  transform: scale(1.2);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: var(--ink-2);
  border: 1px solid var(--line);
  border-radius: 10px;
  padding: 24px;
  max-width: 400px;
  width: 90%;
}

.modal h3 {
  margin-top: 0;
  margin-bottom: 16px;
  color: var(--text);
  font-size: 18px;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.modal-buttons {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid var(--line);
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 150ms;
}

.btn-primary {
  background: var(--orange);
  color: var(--ink-1);
}

.btn-primary:hover {
  background: #ff6b35;
  transform: scale(1.05);
}

.btn-secondary {
  background: var(--ink-1);
  color: var(--text);
  border: 1px solid var(--line);
}

.btn-secondary:hover {
  border-color: var(--orange);
}

@media (max-width: 1024px) {
  .prospects-table {
    font-size: 12px;
  }

  .prospects-table th,
  .prospects-table td {
    padding: 8px 12px;
  }
}
</style>
