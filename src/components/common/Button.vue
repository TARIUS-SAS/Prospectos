<template>
  <button
    :class="[
      'px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
      variantClasses,
    ]"
    :disabled="disabled"
    v-bind="$attrs"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  disabled: false,
})

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'bg-[#b87333] text-white hover:bg-[#a0642b]'
    case 'secondary':
      return 'bg-[#d4c4bb] text-[#1a2735] hover:bg-[#c4b4ab]'
    case 'danger':
      return 'bg-[#ef4444] text-white hover:bg-[#dc2626]'
    default:
      return ''
  }
})
</script>
