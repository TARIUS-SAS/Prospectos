<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-4xl mx-auto">
      <h1 class="text-3xl font-bold text-[#1a2735] mb-8">Mis búsquedas</h1>

      <div class="space-y-4">
        <div v-if="searches.length === 0" class="text-center py-8">
          <p class="text-[#6b7280]">No hay búsquedas realizadas</p>
          <router-link to="/search">
            <Button variant="primary" class="mt-4">Nueva búsqueda</Button>
          </router-link>
        </div>

        <Card v-for="search in searches" :key="search.id" highlight="none" class="cursor-pointer hover:shadow-lg">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="font-bold text-[#1a2735]">{{ search.query }}</h3>
              <p class="text-sm text-[#6b7280]">{{ search.cantidad_resultados_obtenida }} resultados</p>
              <p class="text-xs text-[#6b7280] mt-1">{{ formatDate(search.timestamp) }}</p>
            </div>
            <div class="text-right">
              <p class="font-bold text-[#b87333]">${{ search.costo_total_venta.toFixed(2) }}</p>
              <Button variant="secondary" class="mt-2 text-sm">Ver resultados</Button>
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

const searches = ref<any[]>([])
const authStore = useAuthStore()
const supabase = useSupabase()

function formatDate(date: string) {
  return new Date(date).toLocaleDateString('es-ES')
}

async function loadSearches() {
  if (!authStore.user?.id) return

  const { data } = await supabase.client
    .from('searches')
    .select('*')
    .eq('usuario_id', authStore.user.id)
    .order('timestamp', { ascending: false })

  if (data) {
    searches.value = data
  }
}

onMounted(() => {
  loadSearches()
})
</script>
