<template>
  <div class="inline-block">
    <span
      :class="[
        'text-gradient-copper-coral',
        `text-${sizeClass}`,
        'font-display font-bold transition-all duration-400',
        animated && 'animate-float-up'
      ]"
    >
      {{ formattedValue }}
    </span>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  value: {
    type: Number,
    required: true
  },
  animated: {
    type: Boolean,
    default: true
  },
  size: {
    type: String,
    enum: ['sm', 'md', 'lg'],
    default: 'md'
  }
})

const displayValue = ref(props.value)

const sizeClass = computed(() => {
  const sizes = {
    sm: '2xl',
    md: '4xl',
    lg: '5xl'
  }
  return sizes[props.size]
})

const formattedValue = computed(() => {
  return displayValue.value.toLocaleString('es-EC')
})

watch(() => props.value, (newVal) => {
  displayValue.value = newVal
}, { immediate: true })
</script>

<style scoped>
.animate-float-up {
  animation: floatUp 0.4s ease-out forwards;
}

@keyframes floatUp {
  0% {
    transform: translateY(20px);
    opacity: 0;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}
</style>
