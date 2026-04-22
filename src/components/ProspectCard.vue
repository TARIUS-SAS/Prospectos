<template>
  <router-link :to="{ name: 'ProspectDetail', params: { id: prospect.id } }" class="prospect-card">
    <div>
      <div style="font-weight: 600; color: var(--text); margin-bottom: 4px;">{{ prospect.nombre }}</div>
      <div style="font-size: 13px; color: var(--text-muted); margin-bottom: 8px;">{{ prospect.dirección }}</div>
      <div style="display: flex; gap: 8px; align-items: center;">
        <span style="padding: 4px 8px; background: var(--orange); color: white; border-radius: 4px; font-size: 11px; font-weight: 600;">
          {{ prospect.estado }}
        </span>
        <div style="font-size: 12px; color: var(--text-muted);" v-if="prospect.notas">{{ prospect.notas.substring(0, 20) }}...</div>
      </div>
    </div>
    <div style="text-align: right;">
      <div style="font-size: 24px; font-weight: 700; background: linear-gradient(135deg, var(--orange), #ff6b35); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">
        {{ prospect.score }}
      </div>
      <div v-if="prospect.es_caliente" style="font-size: 11px; color: var(--orange); font-weight: 600;">🔥 CALIENTE</div>
    </div>
  </router-link>
</template>

<script setup lang="ts">
defineProps({
  prospect: {
    type: Object,
    required: true,
  },
})
</script>

<style scoped>
.prospect-card {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 20px;
  background: var(--ink-2);
  border: 1px solid var(--line-soft);
  border-radius: 10px;
  margin-bottom: 12px;
  transition: all 180ms ease-out;
  text-decoration: none;
  color: inherit;
}

.prospect-card:hover {
  border-color: var(--orange);
  box-shadow: 0 8px 16px rgba(255, 159, 67, 0.1);
}
</style>
