<template>
  <div>
    <div style="display: flex; gap: 8px; border-bottom: 2px solid var(--line); margin-bottom: 24px;">
      <button
        v-for="tab in tabs"
        :key="tab"
        @click="activeTab = tab"
        :style="[
          'padding: 12px 16px; border: none; background: none; cursor: pointer; font-weight: 500; font-size: 14px; transition: all 200ms ease-out;',
          activeTab === tab
            ? 'color: var(--orange); border-bottom: 2px solid var(--orange); margin-bottom: -2px;'
            : 'color: var(--text-muted); border-bottom: 2px solid transparent;'
        ]"
      >
        {{ tab }}
      </button>
    </div>

    <slot :activeTab="activeTab"></slot>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

defineProps({
  tabs: {
    type: Array as () => string[],
    required: true,
  },
  defaultTab: {
    type: String,
    default: undefined,
  },
})

const emit = defineEmits(['update:activeTab'])

const activeTab = ref('')

// Initialize with first tab or defaultTab
function initialize() {
  if (props.defaultTab && props.tabs.includes(props.defaultTab)) {
    activeTab.value = props.defaultTab
  } else if (props.tabs.length > 0) {
    activeTab.value = props.tabs[0]
  }
}

const props = defineProps({
  tabs: { type: Array as () => string[], required: true },
  defaultTab: { type: String, default: '' }
})

initialize()
</script>
