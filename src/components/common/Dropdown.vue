<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" class="text-sm font-medium text-[#1a2735]">
      {{ label }}
      <span v-if="required" class="text-[#ef4444]">*</span>
    </label>
    <select
      :value="modelValue"
      @change="$emit('update:modelValue', $event.target.value)"
      :disabled="disabled"
      :required="required"
      :class="[
        'px-3 py-2 rounded-lg border-2 transition-colors',
        'focus:outline-none focus:border-[#b87333]',
        error ? 'border-[#ef4444]' : 'border-[#d4c4bb]',
        disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white',
      ]"
    >
      <option value="">{{ placeholder }}</option>
      <option v-for="opt in options" :key="opt.value" :value="opt.value">
        {{ opt.label }}
      </option>
    </select>
    <span v-if="error" class="text-sm text-[#ef4444]">{{ error }}</span>
  </div>
</template>

<script setup lang="ts">
export interface Option {
  value: string
  label: string
}

export interface Props {
  modelValue: string
  options: Option[]
  label?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
}

withDefaults(defineProps<Props>(), {
  placeholder: 'Selecciona una opción',
  disabled: false,
  required: false,
})

defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>
