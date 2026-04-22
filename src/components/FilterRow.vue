<template>
  <div style="display: grid; grid-template-columns: 1fr 1fr 60px; gap: 12px; align-items: flex-end;">
    <select v-model="localField" class="select" @change="$emit('update:field', localField)">
      <option value="zona">Zona</option>
      <option value="tipo_negocio">Tipo negocio</option>
      <option value="nombre">Nombre</option>
      <option value="empleados_range">Empleados</option>
      <option value="presencia_web">Presencia web</option>
    </select>

    <component :is="inputComponent" v-bind="inputProps" class="input" v-model="localValue" @update:modelValue="$emit('update:value', localValue)" />

    <button v-if="canRemove" @click="$emit('remove')" class="btn btn-secondary" style="padding: 8px 12px; height: auto;">✕</button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

const props = defineProps({
  field: {
    type: String as () => 'zona' | 'tipo_negocio' | 'nombre' | 'empleados_range' | 'presencia_web',
    required: true,
  },
  value: String,
  canRemove: Boolean,
})

const emit = defineEmits(['update:field', 'update:value', 'remove'])

const localField = ref(props.field)
const localValue = ref(props.value || '')

watch(() => props.field, (newVal) => { localField.value = newVal })
watch(() => props.value, (newVal) => { localValue.value = newVal || '' })

const fieldOptions = {
  zona: ['Centro', 'Cumbayá', 'La Carolina', 'Quito Norte', 'Quito Sur'],
  tipo_negocio: ['Café', 'Ferretería', 'Farmacia', 'Restaurante', 'Boutique'],
  nombre: [],
  empleados_range: ['1-5', '5-20', '20-50', '50+'],
  presencia_web: ['sin_web', 'redes', 'website'],
}

const inputComponent = computed(() => {
  if (fieldOptions[localField.value]?.length > 0) return 'select'
  return 'input'
})

const inputProps = computed(() => {
  if (inputComponent.value === 'select') {
    return {
      modelValue: localValue.value,
      options: fieldOptions[localField.value],
    }
  }
  return { modelValue: localValue.value, type: 'text', placeholder: 'Ingresa valor...' }
})
</script>

<style scoped>
select, input {
  width: 100%;
}
</style>
