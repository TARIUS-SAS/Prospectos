<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-4xl mx-auto">
      <h1 class="text-3xl font-bold text-[#1a2735] mb-8">Prospectos guardados</h1>

      <div class="mb-6 flex gap-2">
        <Dropdown
          v-model="filterEstado"
          label="Filtrar por estado"
          :options="estadoOptions"
          placeholder="Todos los estados"
        />
      </div>

      <div class="space-y-4">
        <div v-if="savedProspects.length === 0" class="text-center py-8">
          <p class="text-[#6b7280]">No hay prospectos guardados</p>
          <router-link to="/search">
            <Button variant="primary" class="mt-4">Buscar prospectos</Button>
          </router-link>
        </div>

        <Card
          v-for="saved in savedProspects"
          :key="saved.id"
          :highlight="saved.prospect.es_caliente ? 'hot' : 'none'"
          class="cursor-pointer hover:shadow-lg"
        >
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <h3 class="font-bold text-[#1a2735]">{{ saved.prospect.nombre }}</h3>
              <p class="text-sm text-[#6b7280]">{{ saved.prospect.dirección }}</p>
              <p class="text-sm mt-2">Score: {{ saved.prospect.score }}</p>
              <p class="text-xs text-[#6b7280] mt-1">
                Estado: <span class="font-bold">{{ saved.estado }}</span>
              </p>
              <p v-if="saved.notas" class="text-sm text-[#6b7280] mt-2">📝 {{ saved.notas }}</p>
            </div>
            <div class="text-right">
              <router-link :to="{ name: 'ProspectDetail', params: { id: saved.prospect_id } }">
                <Button variant="primary" class="mb-2">Ver detalle</Button>
              </router-link>
              <Dropdown
                v-model="saved.estado"
                :options="estadoOptions"
                class="text-sm"
              />
            </div>
          </div>
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from './../stores/authStore'
import { useSupabase } from './../composables/useSupabase'
import Header from './../components/layout/Header.vue'
import Card from './../components/common/Card.vue'
import Button from './../components/common/Button.vue'
import Dropdown from './../components/common/Dropdown.vue'

const savedProspects = ref<any[]>([])
const filterEstado = ref('')
const authStore = useAuthStore()
const supabase = useSupabase()

const estadoOptions = [
  { value: 'Nuevo', label: 'Nuevo' },
  { value: 'Contactado', label: 'Contactado' },
  { value: 'Interesado', label: 'Interesado' },
  { value: 'Rechazado', label: 'Rechazado' },
  { value: 'Ganado', label: 'Ganado' },
]

async function loadSavedProspects() {
  if (!authStore.user?.id) return

  const { data } = await supabase.client
    .from('saved_prospects')
    .select(`id, estado, notas, prospect_id, prospects(*)`)
    .eq('usuario_id', authStore.user.id)
    .order('created_at', { ascending: false })

  if (data) {
    savedProspects.value = data.map((saved: any) => ({
      ...saved,
      prospect: saved.prospects,
    }))
  }
}

onMounted(() => {
  loadSavedProspects()
})
</script>
