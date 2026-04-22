<template>
  <div
    :class="[
      'rounded-lg border border-gray-200 bg-white p-4 shadow-sm hover:shadow-md transition-all duration-300',
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
    return 'bg-green-50 border-success'
  }
  return ''
})
</script>
