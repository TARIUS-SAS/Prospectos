<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" class="text-sm font-medium text-navy font-body">
      {{ label }}
      <span v-if="required" class="text-error">*</span>
    </label>
    <select
      :value="modelValue"
      @change="$emit('update:modelValue', $event.target.value)"
      :disabled="disabled"
      :required="required"
      :class="[
        'px-3 py-2 rounded-lg border-2 transition-colors duration-300 font-body',
        'focus:outline-none focus:border-copper focus:shadow-[0_0_0_3px_rgba(184,115,51,0.1)]',
        error ? 'border-error text-error' : 'border-gray-200 text-navy',
        disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white',
      ]"
    >
      <option value="">{{ placeholder }}</option>
      <option v-for="opt in options" :key="opt.value" :value="opt.value">
        {{ opt.label }}
      </option>
    </select>
    <span v-if="error" class="text-sm text-error font-body">{{ error }}</span>
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
