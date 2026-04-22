<template>
  <div
    :class="[
      'rounded-asymmetric bg-white',
      dynamicShadow && 'shadow-dynamic',
      clickable && 'cursor-pointer'
    ]"
  >
    <slot />
  </div>
</template>

<script setup>
defineProps({
  dynamicShadow: {
    type: Boolean,
    default: true
  },
  clickable: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.rounded-asymmetric {
  border-radius: 0 8px 8px 8px;
}

.shadow-dynamic {
  box-shadow: 0 4px 12px rgba(26, 39, 53, 0.1);
  transition: box-shadow 0.3s ease-out, transform 0.3s ease-out;
}

.shadow-dynamic:hover {
  box-shadow: 0 20px 25px rgba(26, 39, 53, 0.15);
  transform: translateY(-4px);
}

.cursor-pointer {
  cursor: pointer;
}
</style>
