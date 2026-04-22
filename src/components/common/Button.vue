<template>
  <button
    :class="[
      'rounded-lg font-medium transition-all duration-300',
      'disabled:opacity-50 disabled:cursor-not-allowed',
      'hover:scale-105 active:scale-95',
      sizeClasses,
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
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  disabled: false,
  size: 'md',
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-3 py-2 text-sm'
    case 'md':
      return 'px-4 py-2.5 text-base'
    case 'lg':
      return 'px-6 py-3 text-lg'
    default:
      return ''
  }
})

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'bg-copper text-white hover:shadow-lg'
    case 'secondary':
      return 'border-2 border-copper text-copper bg-transparent hover:bg-copper/5'
    case 'danger':
      return 'bg-error text-white hover:shadow-lg'
    default:
      return ''
  }
})
</script>

<style scoped>
button {
  will-change: transform;
}
</style>
