<template>
  <div class="flex flex-col gap-2">
    <label v-if="label" class="text-sm font-medium text-[#1a2735]">
      {{ label }}
      <span v-if="required" class="text-[#ef4444]">*</span>
    </label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :required="required"
      @input="$emit('update:modelValue', $event.target.value)"
      :class="[
        'px-3 py-2 rounded-lg border-2 transition-colors',
        'focus:outline-none focus:border-[#b87333]',
        error ? 'border-[#ef4444]' : 'border-[#d4c4bb]',
        disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white',
      ]"
    />
    <span v-if="error" class="text-sm text-[#ef4444]">{{ error }}</span>
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
