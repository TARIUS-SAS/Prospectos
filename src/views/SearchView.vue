<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-4xl mx-auto">
      <h1 class="text-3xl font-bold text-[#1a2735] mb-8">Nueva búsqueda avanzada</h1>

      <Card highlight="none" class="mb-6">
        <form @submit.prevent="handleSearch" class="space-y-4">
          <div class="space-y-2">
            <label class="text-sm font-medium text-[#1a2735]">Parámetros de búsqueda (mínimo 1)</label>
          </div>

          <Dropdown
            v-model="filters.zona"
            label="Zona"
            :options="zonas"
            placeholder="Selecciona zona"
          />

          <Dropdown
            v-model="filters.tipo_negocio"
            label="Tipo de negocio"
            :options="tiposNegocio"
            placeholder="Selecciona tipo"
          />

          <Input
            v-model="filters.nombre"
            label="Nombre"
            placeholder="Buscar por nombre"
          />

          <Dropdown
            v-model="filters.empleados_range"
            label="Rango de empleados"
            :options="rangosEmpleados"
            placeholder="Selecciona rango"
          />

          <Dropdown
            v-model="filters.presencia_web"
            label="Presencia web"
            :options="presenciaWebOptions"
            placeholder="Selecciona tipo"
          />

          <div class="bg-blue-50 p-4 rounded-lg border-l-4 border-blue-400">
            <p class="text-sm text-blue-900 mb-2">
              💰 <strong>Costo estimado:</strong>
            </p>
            <p class="text-lg font-bold text-blue-900">
              ${{ estimatedCost.toFixed(2) }}
            </p>
            <p class="text-xs text-blue-700 mt-1">
              {{ filtrosCuenta }} criterios + {{ cantidadResultados }} empresas
            </p>
          </div>

          <div class="flex gap-2 items-end">
            <div class="flex-1">
              <label class="text-sm font-medium text-[#1a2735]">Cantidad de resultados</label>
              <Input
                v-model.number="cantidadResultados"
                type="number"
                min="1"
                max="50"
              />
            </div>
            <Button variant="primary" type="submit" :disabled="isLoading || !puedeSearch">
              {{ isLoading ? 'Buscando...' : '🔍 Buscar' }}
            </Button>
          </div>

          <Button variant="secondary" type="button" @click="limpiarFiltros" class="w-full">
            Limpiar
          </Button>
        </form>
      </Card>

      <!-- Resultados -->
      <div v-if="isLoading" class="text-center py-8">
        <p class="text-[#6b7280]">Buscando... encontrados: {{ resultados.length }}</p>
      </div>

      <div v-else-if="resultados.length > 0" class="space-y-4">
        <p class="text-[#6b7280]">{{ resultados.length }} resultados encontrados</p>
        <router-link
          v-for="prospect in resultados"
          :key="prospect.id"
          :to="{ name: 'ProspectDetail', params: { id: prospect.id } }"
          class="block"
        >
          <Card :highlight="prospect.es_caliente ? 'hot' : 'none'" class="cursor-pointer hover:shadow-lg">
            <div class="flex justify-between items-start">
              <div>
                <h3 class="font-bold text-[#1a2735]">{{ prospect.nombre }}</h3>
                <p class="text-sm text-[#6b7280]">{{ prospect.dirección }}</p>
                <p class="text-sm mt-2">
                  📞 <a :href="`tel:${prospect.teléfono}`" class="text-[#b87333] hover:underline">{{ prospect.teléfono }}</a>
                </p>
              </div>
              <div class="text-right">
                <p :class="['text-2xl font-bold', prospect.es_caliente ? 'text-[#22c55e]' : 'text-[#6b7280]']">
                  {{ prospect.score }}
                </p>
                <p v-if="prospect.es_caliente" class="text-xs text-[#22c55e] font-bold">CALIENTE</p>
              </div>
            </div>
          </Card>
        </router-link>
      </div>

      <div v-else-if="errorSearch" class="text-center py-8">
        <p class="text-[#ef4444]">{{ errorSearch }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Header from '@/components/layout/Header.vue'
import Card from '@/components/common/Card.vue'
import Input from '@/components/common/Input.vue'
import Dropdown from '@/components/common/Dropdown.vue'
import Button from '@/components/common/Button.vue'
import { useCosts } from '@/composables/useCosts'
import { useSupabase } from '@/composables/useSupabase'

const { calculateSearchCost } = useCosts()
const supabase = useSupabase()

const filters = ref({
  zona: '',
  tipo_negocio: '',
  nombre: '',
  empleados_range: '',
  presencia_web: '',
})

const cantidadResultados = ref(20)
const resultados = ref<any[]>([])
const isLoading = ref(false)
const errorSearch = ref('')

const zonas = [
  { value: 'Centro', label: 'Centro' },
  { value: 'Cumbayá', label: 'Cumbayá' },
  { value: 'La Carolina', label: 'La Carolina' },
  { value: 'Quito Norte', label: 'Quito Norte' },
  { value: 'Quito Sur', label: 'Quito Sur' },
]

const tiposNegocio = [
  { value: 'Café', label: 'Café' },
  { value: 'Ferretería', label: 'Ferretería' },
  { value: 'Farmacia', label: 'Farmacia' },
  { value: 'Restaurante', label: 'Restaurante' },
  { value: 'Boutique', label: 'Boutique' },
]

const rangosEmpleados = [
  { value: '1-5', label: '1-5 empleados' },
  { value: '5-20', label: '5-20 empleados' },
  { value: '20-50', label: '20-50 empleados' },
  { value: '50+', label: '50+ empleados' },
]

const presenciaWebOptions = [
  { value: 'sin_web', label: 'Sin website' },
  { value: 'redes', label: 'Solo redes' },
  { value: 'website', label: 'Website activo' },
]

const filtrosCuenta = computed(() => {
  return Object.values(filters.value).filter(v => v !== '').length
})

const puedeSearch = computed(() => filtrosCuenta.value > 0)

const estimatedCost = computed(() => {
  if (!puedeSearch.value) return 0
  return calculateSearchCost(cantidadResultados.value, filtrosCuenta.value)
})

async function handleSearch() {
  if (!puedeSearch.value) return

  isLoading.value = true
  errorSearch.value = ''

  try {
    const token = (await supabase.client.auth.getSession()).data.session?.access_token
    if (!token) {
      throw new Error('No autenticado')
    }

    const response = await supabase.callEdgeFunction('search-google-places', {
      query: filters.value.nombre || `${filters.value.tipo_negocio || 'negocios'} ${filters.value.zona}`,
      zona: filters.value.zona,
      tipo_negocio: filters.value.tipo_negocio || null,
      nombre: filters.value.nombre || null,
      empleados_range: filters.value.empleados_range || null,
      presencia_web: filters.value.presencia_web || null,
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
  filters.value = {
    zona: '',
    tipo_negocio: '',
    nombre: '',
    empleados_range: '',
    presencia_web: '',
  }
  resultados.value = []
  errorSearch.value = ''
}
</script>
