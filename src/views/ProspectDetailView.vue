<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-4xl mx-auto">
      <router-link to="/search" class="text-[#b87333] hover:underline text-sm mb-4 inline-block">
        ← Volver
      </router-link>

      <Card highlight="none" class="mb-6">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h1 class="text-3xl font-bold text-[#1a2735]">{{ prospect.nombre }}</h1>
            <p class="text-sm text-[#6b7280]">{{ prospect.dirección }}</p>
          </div>
          <div class="text-right">
            <p :class="['text-4xl font-bold', prospect.es_caliente ? 'text-[#22c55e]' : 'text-[#6b7280]']">
              {{ prospect.score }}
            </p>
            <p v-if="prospect.es_caliente" class="text-sm text-[#22c55e] font-bold">🔥 CALIENTE</p>
          </div>
        </div>

        <!-- Tabs -->
        <div class="border-b-2 border-[#d4c4bb] mb-6 flex gap-4">
          <button
            v-for="tab in tabs"
            :key="tab"
            @click="activeTab = tab"
            :class="[
              'pb-3 font-medium transition-colors border-b-4',
              activeTab === tab
                ? 'text-[#b87333] border-[#b87333]'
                : 'text-[#6b7280] border-transparent hover:text-[#1a2735]',
            ]"
          >
            {{ tab }}
          </button>
        </div>

        <!-- Tab Content: Actual -->
        <div v-if="activeTab === 'Actual'" class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <p class="text-xs font-medium text-[#6b7280] uppercase">Contacto</p>
              <p class="text-lg">
                📞 <a :href="`tel:${prospect.teléfono}`" class="text-[#b87333] hover:underline">
                  {{ prospect.teléfono }}
                </a>
              </p>
            </div>
            <div>
              <p class="text-xs font-medium text-[#6b7280] uppercase">Website</p>
              <p class="text-lg">
                {{ prospect.website ? '🌐 ' + prospect.website : '(Sin website)' }}
                {{ prospect.https ? ' ✓ HTTPS' : '' }}
              </p>
            </div>
            <div>
              <p class="text-xs font-medium text-[#6b7280] uppercase">SRI</p>
              <p class="text-lg">{{ prospect.sri_activo ? '✓ Activo' : '✗ Inactivo' }}</p>
            </div>
            <div>
              <p class="text-xs font-medium text-[#6b7280] uppercase">Rating</p>
              <p class="text-lg">⭐ {{ prospect.google_rating }}/5.0</p>
            </div>
          </div>

          <div class="mt-6 p-4 bg-gray-50 rounded-lg">
            <p class="text-xs font-medium text-[#6b7280] uppercase mb-3">Desglose de Score</p>
            <div class="space-y-2">
              <div
                v-for="(value, key) in prospect.desglose"
                :key="key"
                class="flex justify-between text-sm"
              >
                <span>{{ key }}</span>
                <span class="font-bold">+{{ value }}</span>
              </div>
            </div>
          </div>

          <Button variant="primary" class="w-full">🔄 Actualizar datos ($0.10)</Button>
        </div>

        <!-- Tab Content: Anterior (placeholder) -->
        <div v-if="activeTab === 'Anterior'" class="text-center py-8">
          <p class="text-[#6b7280]">Sin versión anterior</p>
        </div>

        <!-- Tab Content: Comparación (placeholder) -->
        <div v-if="activeTab === 'Comparación'" class="text-center py-8">
          <p class="text-[#6b7280]">Sin cambios para comparar</p>
        </div>

        <!-- Actions -->
        <div class="mt-6 flex gap-2">
          <Button variant="primary" class="flex-1">💾 Guardar</Button>
          <Button variant="secondary" class="flex-1">Eliminar</Button>
        </div>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Header from './../components/layout/Header.vue'
import Card from './../components/common/Card.vue'
import Button from './../components/common/Button.vue'
const activeTab = ref('Actual')
const tabs = ['Actual', 'Anterior', 'Comparación']

const prospect = ref({
  id: '',
  nombre: '',
  dirección: '',
  teléfono: '',
  website: '',
  https: false,
  sri_activo: false,
  google_rating: 4.5,
  score: 24,
  es_caliente: true,
  desglose: {
    sin_website: 10,
    sri_activo: 3,
    tiene_teléfono: 2,
    zona_comercial: 2,
  },
})

</script>
