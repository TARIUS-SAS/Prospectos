<template>
  <div
    :class="[
      'rounded-lg border-2 border-[#d4c4bb] bg-white p-4 shadow-sm hover:shadow-md transition-shadow',
      highlightClass,
    ]"
  >
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface Props {
  highlight?: 'hot' | 'none'
}

const props = withDefaults(defineProps<Props>(), {
  highlight: 'none',
})

const highlightClass = computed(() => {
  if (props.highlight === 'hot') {
    return 'bg-green-50 border-[#22c55e]'
  }
  return ''
})
</script>
