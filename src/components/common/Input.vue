<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" class="text-sm font-medium text-navy font-body">
      {{ label }}
      <span v-if="required" class="text-error">*</span>
    </label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :required="required"
      @input="$emit('update:modelValue', $event.target.value)"
      :class="[
        'px-3 py-2.5 rounded-lg border-2 transition-all duration-300',
        'font-body text-base placeholder-gray-400',
        'focus:outline-none',
        error ? 'border-error focus:border-error focus:shadow-[0_0_0_3px_rgba(239,68,68,0.1)]' : 'border-gray-200 focus:border-copper focus:shadow-[0_0_0_3px_rgba(184,115,51,0.1)]',
        disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white',
      ]"
    />
    <span v-if="error" class="text-xs text-error font-body">{{ error }}</span>
  </div>
</template>

<script setup lang="ts">
export interface Props {
  modelValue: string | number
  type?: 'text' | 'email' | 'password' | 'number'
  label?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
}

withDefaults(defineProps<Props>(), {
  type: 'text',
  disabled: false,
  required: false,
})

defineEmits<{
  'update:modelValue': [value: string | number]
}>()
</script>
