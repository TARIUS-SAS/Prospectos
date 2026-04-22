<template>
  <AsymmetricCard class="p-6 bg-white">
    <div class="flex flex-col gap-3">
      <span class="text-sm font-medium text-gray-600 font-body">
        {{ label }}
      </span>
      <GradientNumber :value="value" :size="size" :animated="animated" />
      <span v-if="description" class="text-xs text-gray-500 font-body">
        {{ description }}
      </span>
    </div>
  </AsymmetricCard>
</template>

<script setup>
import GradientNumber from './GradientNumber.vue'
import AsymmetricCard from './AsymmetricCard.vue'

defineProps({
  label: {
    type: String,
    required: true
  },
  value: {
    type: Number,
    required: true
  },
  description: {
    type: String,
    default: null
  },
  size: {
    type: String,
    enum: ['sm', 'md', 'lg'],
    default: 'md'
  },
  animated: {
    type: Boolean,
    default: true
  }
})
</script>
