<template>
  <div :class="['w-full h-8 flex items-center', animated && 'animate-wave-pulse']">
    <svg
      class="w-full"
      viewBox="0 0 1200 50"
      preserveAspectRatio="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        :stroke="colorHex"
        :stroke-width="strokeWidth"
        :opacity="opacityValue"
        fill="none"
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M 0,25 Q 150,10 300,25 T 600,25 T 900,25 T 1200,25"
      />
    </svg>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  color: {
    type: String,
    default: 'copper',
    validator: (val) => ['copper', 'navy', 'coral', 'cream'].includes(val)
  },
  opacity: {
    type: Number,
    default: 0.2,
    validator: (val) => val >= 0 && val <= 1
  },
  animated: {
    type: Boolean,
    default: true
  },
  strokeWidth: {
    type: Number,
    default: 2
  }
})

const colorMap = {
  copper: '#b87333',
  navy: '#1a2735',
  coral: '#ff6b35',
  cream: '#e8d8cb'
}

const colorHex = computed(() => colorMap[props.color])
const opacityValue = computed(() => props.opacity.toString())
</script>

<style scoped>
.animate-wave-pulse {
  animation: wavePulse 1.5s ease-in-out infinite;
}

@keyframes wavePulse {
  0%, 100% {
    opacity: 0.4;
  }
  50% {
    opacity: 1;
  }
}
</style>
