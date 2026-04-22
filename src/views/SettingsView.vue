<template>
  <div class="min-h-screen bg-[#e8d8cb] p-6">
    <Header />

    <div class="max-w-2xl mx-auto">
      <h1 class="text-3xl font-bold text-[#1a2735] mb-8">Configuración</h1>

      <Card highlight="none" class="mb-6">
        <div class="space-y-4">
          <div>
            <p class="text-sm font-medium text-[#1a2735] mb-2">Email</p>
            <Input v-model="settings.email" type="email" disabled />
          </div>

          <div>
            <p class="text-sm font-medium text-[#1a2735] mb-2">Plan actual</p>
            <p class="text-lg text-[#b87333] font-bold">{{ settings.plan }}</p>
          </div>

          <Button variant="secondary" class="w-full">Cambiar plan</Button>
        </div>
      </Card>

      <Card highlight="none" class="mb-6">
        <h3 class="font-bold text-[#1a2735] mb-4">Búsquedas</h3>
        <div class="space-y-4">
          <Input
            v-model.number="settings.búsquedas_max"
            type="number"
            label="Búsquedas máximas por día"
            min="1"
            max="999"
          />
          <Input
            v-model.number="settings.resultados_por_defecto"
            type="number"
            label="Resultados por defecto"
            min="1"
            max="50"
          />
          <Button variant="primary" @click="saveSearchSettings">Guardar cambios</Button>
        </div>
      </Card>

      <Card highlight="none">
        <h3 class="font-bold text-[#1a2735] mb-4">Contraseña</h3>
        <Button variant="secondary" class="w-full">Cambiar contraseña</Button>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Header from '@/components/layout/Header.vue'
import Card from '@/components/common/Card.vue'
import Input from '@/components/common/Input.vue'
import Button from '@/components/common/Button.vue'

const settings = ref({
  email: '',
  plan: 'Starter',
  búsquedas_max: 20,
  resultados_por_defecto: 20,
})

function saveSearchSettings() {
  // TODO: Guardar en BD
}

onMounted(() => {
  // TODO: Cargar settings del usuario
})
</script>
