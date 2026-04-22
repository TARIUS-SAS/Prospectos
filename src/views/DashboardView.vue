<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-7xl mx-auto">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-[#1a2735] mb-2">Dashboard</h1>
        <p class="text-[#6b7280]">Bienvenido a tu prospector de negocios</p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        <!-- Today's consumption -->
        <Card highlight="none">
          <div class="space-y-3">
            <h3 class="font-bold text-[#1a2735]">Mi consumo hoy</h3>
            <div class="space-y-1 text-sm">
              <p class="flex justify-between">
                <span>Búsquedas: {{ costStore.dailyCost.búsquedas }}</span>
              </p>
              <p class="flex justify-between">
                <span>Empresas: {{ costStore.dailyCost.empresas }}</span>
              </p>
              <p class="flex justify-between">
                <span>Guardados: {{ costStore.dailyCost.guardados }}</span>
              </p>
            </div>
            <div class="pt-2 border-t border-[#d4c4bb]">
              <p class="font-bold text-lg text-[#b87333]">${{ costStore.dailyCost.total.toFixed(2) }}</p>
            </div>
          </div>
        </Card>

        <!-- Monthly consumption -->
        <Card highlight="none">
          <div class="space-y-3">
            <h3 class="font-bold text-[#1a2735]">Consumo este mes</h3>
            <div class="space-y-1 text-sm">
              <p class="flex justify-between">
                <span>Búsquedas: {{ costStore.monthlyCost.búsquedas }}</span>
              </p>
              <p class="flex justify-between">
                <span>Empresas: {{ costStore.monthlyCost.empresas }}</span>
              </p>
              <p class="flex justify-between">
                <span>Guardados: {{ costStore.monthlyCost.guardados }}</span>
              </p>
            </div>
            <div class="pt-2 border-t border-[#d4c4bb]">
              <p class="font-bold text-lg text-[#b87333]">${{ costStore.monthlyCost.total.toFixed(2) }}</p>
            </div>
          </div>
        </Card>

        <!-- Plan info -->
        <Card highlight="none">
          <div class="space-y-3">
            <h3 class="font-bold text-[#1a2735]">Mi plan</h3>
            <p class="text-sm text-[#6b7280]">Starter</p>
            <p class="text-sm">Búsquedas disponibles hoy: <span class="font-bold text-[#22c55e]">17 de 20</span></p>
            <Button variant="secondary" class="w-full text-sm">
              Cambiar plan
            </Button>
          </div>
        </Card>
      </div>

      <!-- Quick Actions -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <router-link to="/search" class="block">
          <Button variant="primary" class="w-full">
            🔍 Nueva búsqueda
          </Button>
        </router-link>
        <router-link to="/history" class="block">
          <Button variant="secondary" class="w-full">
            📂 Mis búsquedas
          </Button>
        </router-link>
        <router-link to="/saved" class="block">
          <Button variant="secondary" class="w-full">
            💾 Guardados
          </Button>
        </router-link>
        <router-link to="/settings" class="block">
          <Button variant="secondary" class="w-full">
            ⚙️ Configuración
          </Button>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useCostStore } from '@/stores/costStore'
import Header from '@/components/layout/Header.vue'
import Card from '@/components/common/Card.vue'
import Button from '@/components/common/Button.vue'

const costStore = useCostStore()

onMounted(() => {
  // Load costs from Supabase
  // TODO: implement in phase 2
})
</script>
