<template>
  <Teleport to="body" v-if="modelValue">
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg max-w-md w-full mx-4 p-6">
        <div v-if="title" class="text-lg font-bold text-[#1a2735] mb-4">
          {{ title }}
        </div>
        <div class="text-[#1a2735] mb-6">
          <slot />
        </div>
        <div class="flex gap-3 justify-end">
          <Button
            variant="secondary"
            @click="$emit('update:modelValue', false)"
          >
            {{ cancelText }}
          </Button>
          <Button
            @click="$emit('confirm')"
          >
            {{ confirmText }}
          </Button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import Button from './Button.vue'

export interface Props {
  modelValue: boolean
  title?: string
  confirmText?: string
  cancelText?: string
}

withDefaults(defineProps<Props>(), {
  confirmText: 'Confirmar',
  cancelText: 'Cancelar',
})

defineEmits<{
  'update:modelValue': [value: boolean]
  'confirm': []
}>()
</script>
