<template>
  <Transition name="check-fade">
    <div v-if="show" class="flex items-center gap-3">
      <svg
        class="animate-check-bounce"
        width="32"
        height="32"
        viewBox="0 0 32 32"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle cx="16" cy="16" r="15" stroke="currentColor" stroke-width="2" class="text-success" />
        <path
          d="M10 16L14.5 20.5L22 11"
          stroke="currentColor"
          stroke-width="2.5"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="text-success"
        />
      </svg>
      <span v-if="message" class="text-sm font-medium text-navy">
        {{ message }}
      </span>
    </div>
  </Transition>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  message: {
    type: String,
    default: null
  },
  autoHideDuration: {
    type: Number,
    default: 3000
  }
})

const emit = defineEmits(['done'])

const isVisible = ref(props.show)

watch(() => props.show, (newVal) => {
  if (newVal) {
    isVisible.value = true
    setTimeout(() => {
      isVisible.value = false
      emit('done')
    }, props.autoHideDuration)
  }
})
</script>

<style scoped>
.animate-check-bounce {
  animation: checkBounce 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

@keyframes checkBounce {
  0% {
    transform: scale(0) rotate(-90deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.1) rotate(10deg);
  }
  100% {
    transform: scale(1) rotate(0deg);
    opacity: 1;
  }
}

.check-fade-enter-active,
.check-fade-leave-active {
  transition: opacity 0.3s ease-out;
}

.check-fade-enter-from,
.check-fade-leave-to {
  opacity: 0;
}
</style>
