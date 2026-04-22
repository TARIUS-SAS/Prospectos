<template>
  <div class="app-content">
    <div class="page-head">
      <div class="page-head-left">
        <p>Prospecto</p>
        <h1>{{ prospect.nombre }}</h1>
      </div>
    </div>

    <div class="page-main" style="max-width: 1000px;">
      <div class="panel" style="margin-bottom: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 24px;">
          <div>
            <h2 style="font-size: 28px; font-weight: 700; color: var(--text); margin-bottom: 8px;">{{ prospect.nombre }}</h2>
            <p style="color: var(--text-muted); font-size: 14px;">{{ prospect.dirección }}</p>
          </div>
          <div style="text-align: right;">
            <div :style="['font-size: 32px; font-weight: 700; line-height: 1;', prospect.es_caliente ? 'color: var(--orange)' : 'color: var(--text-muted)']">
              {{ prospect.score }}
            </div>
            <div v-if="prospect.es_caliente" style="font-size: 12px; color: var(--orange); font-weight: 600; margin-top: 8px;">🔥 CALIENTE</div>
          </div>
        </div>

        <div style="display: flex; gap: 12px; border-bottom: 1px solid var(--line-soft); padding-bottom: 12px; margin-bottom: 20px;">
          <button
            v-for="tab in ['Actual', 'Anterior', 'Comparación']"
            :key="tab"
            @click="activeTab = tab"
            :class="['btn', 'btn-sm', activeTab === tab ? 'btn-primary' : 'btn-ghost']"
          >
            {{ tab }}
          </button>
        </div>

        <div v-if="activeTab === 'Actual'" style="display: grid; gap: 20px;">
          <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;">
            <div style="padding: 16px; background: var(--ink-1); border-radius: 10px; border: 1px solid var(--line-soft);">
              <div style="font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; margin-bottom: 8px;">Contacto</div>
              <a :href="`tel:${prospect.teléfono}`" style="font-size: 14px; color: var(--orange); text-decoration: none;">
                📞 {{ prospect.teléfono }}
              </a>
            </div>
            <div style="padding: 16px; background: var(--ink-1); border-radius: 10px; border: 1px solid var(--line-soft);">
              <div style="font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; margin-bottom: 8px;">Website</div>
              <a v-if="prospect.website" :href="prospect.website" target="_blank" style="font-size: 14px; color: var(--orange); text-decoration: none;">
                🌐 {{ prospect.website }}
              </a>
              <div v-else style="font-size: 14px; color: var(--text-muted);">Sin website</div>
            </div>
            <div style="padding: 16px; background: var(--ink-1); border-radius: 10px; border: 1px solid var(--line-soft);">
              <div style="font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; margin-bottom: 8px;">SRI</div>
              <div style="font-size: 14px; color: var(--text);">{{ prospect.sri || 'N/A' }}</div>
            </div>
            <div style="padding: 16px; background: var(--ink-1); border-radius: 10px; border: 1px solid var(--line-soft);">
              <div style="font-size: 10px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; margin-bottom: 8px;">Rating</div>
              <div style="font-size: 14px; color: var(--orange);">⭐ {{ prospect.rating || 'N/A' }}</div>
            </div>
          </div>

          <div style="padding: 16px; background: var(--ink-1); border-radius: 10px; border: 1px solid var(--line-soft);">
            <div style="font-weight: 600; color: var(--text); margin-bottom: 12px;">Desglose de score</div>
            <div style="display: grid; gap: 8px;">
              <div style="display: flex; justify-content: space-between; font-size: 13px;">
                <span>Sin website</span>
                <span style="color: var(--orange);">+10</span>
              </div>
              <div style="display: flex; justify-content: space-between; font-size: 13px;">
                <span>Tiene teléfono</span>
                <span style="color: var(--orange);">+2</span>
              </div>
              <div style="display: flex; justify-content: space-between; font-size: 13px; padding-top: 8px; border-top: 1px solid var(--line-soft);">
                <span style="font-weight: 600;">Total</span>
                <span style="color: var(--orange); font-weight: 600;">{{ prospect.score }}</span>
              </div>
            </div>
          </div>

          <div style="display: flex; gap: 8px;">
            <button class="btn btn-secondary">Actualizar datos ($0.10)</button>
            <button class="btn btn-primary">Guardar</button>
            <button class="btn btn-danger">Eliminar</button>
          </div>
        </div>

        <div v-else-if="activeTab === 'Anterior'" style="text-align: center; padding: 32px; color: var(--text-muted);">
          Sin versión anterior
        </div>

        <div v-else-if="activeTab === 'Comparación'" style="text-align: center; padding: 32px; color: var(--text-muted);">
          No hay datos para comparar
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const activeTab = ref('Actual')

const prospect = ref({
  id: route.params.id,
  nombre: 'Café Central',
  dirección: 'Av. Amazonas 1234, Quito',
  score: 12,
  es_caliente: false,
  teléfono: '+593 2 123 4567',
  website: '',
  sri: 'Activo',
  rating: 4.5,
})
</script>
