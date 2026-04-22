<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold text-[#1a2735] mb-8">Admin Dashboard</h1>

      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <Card highlight="none">
          <div class="space-y-2">
            <p class="text-sm font-medium text-[#6b7280]">Costo real (mes)</p>
            <p class="text-3xl font-bold text-[#1a2735]">${{ adminStats.costoReal.toFixed(2) }}</p>
          </div>
        </Card>

        <Card highlight="none">
          <div class="space-y-2">
            <p class="text-sm font-medium text-[#6b7280]">Ingresos (mes)</p>
            <p class="text-3xl font-bold text-[#b87333]">${{ adminStats.ingresos.toFixed(2) }}</p>
          </div>
        </Card>

        <Card highlight="none">
          <div class="space-y-2">
            <p class="text-sm font-medium text-[#6b7280]">Margen bruto</p>
            <p class="text-3xl font-bold text-[#22c55e]">{{ adminStats.margenBruto.toFixed(1) }}%</p>
          </div>
        </Card>
      </div>

      <!-- Navigation tabs -->
      <div class="mb-6 flex gap-4 border-b-2 border-[#d4c4bb]">
        <button
          @click="activeTab = 'usuarios'"
          :class="[
            'pb-3 font-medium transition-colors',
            activeTab === 'usuarios' ? 'text-[#b87333] border-b-4 border-[#b87333]' : 'text-[#6b7280]',
          ]"
        >
          Usuarios
        </button>
        <button
          @click="activeTab = 'facturación'"
          :class="[
            'pb-3 font-medium transition-colors',
            activeTab === 'facturación' ? 'text-[#b87333] border-b-4 border-[#b87333]' : 'text-[#6b7280]',
          ]"
        >
          Facturación
        </button>
        <button
          @click="activeTab = 'configuración'"
          :class="[
            'pb-3 font-medium transition-colors',
            activeTab === 'configuración' ? 'text-[#b87333] border-b-4 border-[#b87333]' : 'text-[#6b7280]',
          ]"
        >
          Configuración
        </button>
      </div>

      <!-- Tab: Usuarios -->
      <div v-if="activeTab === 'usuarios'">
        <div class="space-y-4">
          <Card v-for="user in users" :key="user.id" highlight="none" class="cursor-pointer hover:shadow-lg">
            <div class="flex justify-between items-start">
              <div>
                <h3 class="font-bold text-[#1a2735]">{{ user.email }}</h3>
                <p class="text-sm text-[#6b7280]">Plan: {{ user.plan }}</p>
                <p class="text-sm text-[#6b7280]">Estado: {{ user.estado }}</p>
              </div>
              <div class="text-right">
                <p class="font-bold text-[#b87333]">${{ user.consumo.toFixed(2) }}</p>
                <Button variant="secondary" class="mt-2 text-sm">Ver detalle</Button>
              </div>
            </div>
          </Card>
        </div>
      </div>

      <!-- Tab: Facturación -->
      <div v-if="activeTab === 'facturación'" class="text-center py-8">
        <p class="text-[#6b7280]">Reporte de facturación (en desarrollo)</p>
      </div>

      <!-- Tab: Configuración -->
      <div v-if="activeTab === 'configuración'">
        <Card highlight="none">
          <h3 class="font-bold text-[#1a2735] mb-4">Costos operacionales</h3>
          <div class="space-y-4">
            <Input
              v-model.number="config.costGooglePlaces"
              type="number"
              step="0.0001"
              label="Costo Google Places por resultado"
            />
            <Input
              v-model.number="config.costSRI"
              type="number"
              step="0.0001"
              label="Costo SRI por consulta"
            />
            <Button variant="primary">Guardar</Button>
          </div>
        </Card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Header from '@/components/layout/Header.vue'
import Card from '@/components/common/Card.vue'
import Button from '@/components/common/Button.vue'
import Input from '@/components/common/Input.vue'

const activeTab = ref('usuarios')

const adminStats = ref({
  costoReal: 45.23,
  ingresos: 287.50,
  margenBruto: 84.2,
})

const users = ref<any[]>([
  { id: '1', email: 'juan@empresa.com', plan: 'Starter', consumo: 23.05, estado: 'activo' },
  { id: '2', email: 'maria@empresa.com', plan: 'Professional', consumo: 67.43, estado: 'activo' },
])

const config = ref({
  costGooglePlaces: 0.0034,
  costSRI: 0.001,
})
</script>
