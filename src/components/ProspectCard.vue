<template>
  <div class="prospect-card" :class="{ hot: prospect.score >= 70 }">
    <div class="prospect-main">
      <h4>{{ prospect.nombre }}</h4>
      <p class="dirección">{{ prospect.dirección || 'Sin ubicación' }}</p>

      <div class="contact-row">
        <a v-if="prospect.telefono" :href="`tel:${prospect.telefono}`" class="contact-link">
          ☎️ {{ prospect.telefono }}
        </a>
        <a v-if="prospect.website" :href="prospect.website" target="_blank" class="contact-link">
          🌐 Website
        </a>
      </div>

      <div class="meta">
        <span v-if="prospect.google_rating" class="rating">
          ⭐ {{ prospect.google_rating }} ({{ prospect.google_reviews }} reviews)
        </span>
        <span v-if="prospect.sri_activo" class="badge sri">✓ SRI Activo</span>
        <span v-if="prospect.has_facebook || prospect.has_instagram" class="badge social">Redes</span>
      </div>
    </div>

    <div class="prospect-side">
      <div class="score-display" :class="scoreClass">{{ prospect.score }}</div>
      <p v-if="prospect.score >= 70" class="hot-label">CALIENTE</p>
      <p v-else-if="prospect.score >= 50" class="warm-label">CÁLIDO</p>
      <p v-else class="cold-label">Frío</p>

      <button @click="$emit('save')" class="btn btn-sm btn-primary">Guardar</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  prospect: {
    type: Object,
    required: true
  }
})

defineEmits(['save'])

const scoreClass = computed(() => {
  if (props.prospect.score >= 70) return 'hot'
  if (props.prospect.score >= 50) return 'warm'
  return 'cold'
})
</script>

<style scoped>
.prospect-card {
  display: grid;
  grid-template-columns: 1fr 140px;
  gap: 16px;
  padding: 16px;
  background: var(--ink-1);
  border: 1px solid var(--line);
  border-radius: 8px;
  transition: all 200ms ease-out;
}

.prospect-card:hover {
  border-color: var(--orange);
  box-shadow: 0 4px 12px rgba(255, 159, 67, 0.1);
}

.prospect-card.hot {
  border-color: var(--orange);
  background: linear-gradient(135deg, var(--ink-1), rgba(255, 159, 67, 0.05));
}

.prospect-main {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.prospect-main h4 {
  margin: 0;
  font-size: 15px;
  color: var(--text);
  font-weight: 600;
}

.dirección {
  margin: 0;
  font-size: 13px;
  color: var(--text-muted);
}

.contact-row {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.contact-link {
  font-size: 12px;
  color: var(--orange);
  text-decoration: none;
  padding: 4px 8px;
  background: rgba(255, 159, 67, 0.1);
  border-radius: 4px;
  transition: all 150ms;
}

.contact-link:hover {
  background: rgba(255, 159, 67, 0.2);
}

.meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  font-size: 11px;
}

.rating {
  color: var(--text-muted);
}

.badge {
  padding: 2px 8px;
  border-radius: 3px;
  font-weight: 500;
}

.badge.sri {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
}

.badge.social {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.prospect-side {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
}

.score-display {
  font-size: 36px;
  font-weight: 700;
  text-align: center;
  width: 100%;
}

.score-display.hot {
  background: linear-gradient(135deg, var(--orange), #ff6b35);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.score-display.warm {
  color: #f59e0b;
}

.score-display.cold {
  color: var(--text-muted);
}

.hot-label {
  margin: 0;
  font-size: 11px;
  font-weight: 600;
  color: var(--orange);
}

.warm-label {
  margin: 0;
  font-size: 11px;
  font-weight: 600;
  color: #f59e0b;
}

.cold-label {
  margin: 0;
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted);
}
</style>
