<template>
  <Teleport to="body">
    <Transition name="toast-fade">
      <div
        v-if="visible"
        :class="[
          'fixed bottom-4 right-4 px-4 py-3 rounded-lg text-white font-medium shadow-lg font-body',
          typeClasses,
        ]"
      >
        {{ message }}
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'

export interface Props {
  message: string
  type?: 'success' | 'error' | 'info'
  duration?: number
}

const props = withDefaults(defineProps<Props>(), {
  type: 'info',
  duration: 3000,
})

const visible = ref(true)

onMounted(() => {
  setTimeout(() => {
    visible.value = false
  }, props.duration)
})

const typeClasses = computed(() => {
  switch (props.type) {
    case 'success':
      return 'bg-success'
    case 'error':
      return 'bg-error'
    case 'info':
      return 'bg-copper'
    default:
      return ''
  }
})
</script>

<style scoped>
.toast-fade-enter-active,
.toast-fade-leave-active {
  transition: all 300ms ease-out;
}

.toast-fade-enter-from,
.toast-fade-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
</style>
