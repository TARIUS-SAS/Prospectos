<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h2>{{ prospect.nombre }}</h2>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <div class="modal-body">
        <!-- Estado de carga -->
        <div v-if="loading" class="loading">
          <div class="spinner"></div>
          <p>Cargando detalles...</p>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="error-box">
          <p>❌ {{ error }}</p>
        </div>

        <!-- Detalles -->
        <div v-else-if="details" class="details">
          <!-- Info básica -->
          <section class="section">
            <h3>Información General</h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="label">Nombre</span>
                <span class="value">{{ details.nombre }}</span>
              </div>
              <div class="info-item">
                <span class="label">Dirección</span>
                <span class="value">{{ details.direccion }}</span>
              </div>
              <div class="info-item">
                <span class="label">Teléfono</span>
                <span class="value">
                  <a v-if="details.telefono" :href="`tel:${details.telefono}`">{{ details.telefono }}</a>
                  <span v-else class="muted">No disponible</span>
                </span>
              </div>
              <div class="info-item">
                <span class="label">Tipo(s)</span>
                <span class="value">{{ details.tipos?.join(", ") || "No especificado" }}</span>
              </div>
            </div>
          </section>

          <!-- Horarios -->
          <section v-if="details.horarios.length > 0" class="section">
            <h3>Horarios</h3>
            <div class="horarios">
              <div v-for="(horario, i) in details.horarios" :key="i" class="horario-item">
                {{ horario }}
              </div>
              <div v-if="details.abierto_ahora !== undefined" :class="['estado', details.abierto_ahora ? 'abierto' : 'cerrado']">
                {{ details.abierto_ahora ? "🟢 Abierto ahora" : "🔴 Cerrado" }}
              </div>
            </div>
          </section>

          <!-- Web y enlaces -->
          <section v-if="details.website || details.url_google" class="section">
            <h3>Enlaces</h3>
            <div class="enlaces">
              <a v-if="details.website" :href="details.website" target="_blank" class="link">
                🌐 Sitio Web
              </a>
              <a :href="details.url_google" target="_blank" class="link">
                🗺️ Ver en Google Maps
              </a>
            </div>
          </section>

          <!-- Rating y reviews -->
          <section v-if="details.rating || details.reviews.length > 0" class="section">
            <h3>Calificación y Opiniones</h3>
            <div v-if="details.rating" class="rating">
              <span class="stars">⭐ {{ details.rating }}</span>
            </div>
            <div v-if="details.reviews.length > 0" class="reviews">
              <div v-for="(review, i) in details.reviews" :key="i" class="review-item">
                <div class="review-header">
                  <span class="review-author">{{ review.autor }}</span>
                  <span class="review-rating">⭐ {{ review.rating }}</span>
                </div>
                <span class="review-date">{{ review.fecha }}</span>
                <p class="review-text">{{ review.texto }}</p>
              </div>
            </div>
          </section>

          <!-- Fotos -->
          <section v-if="details.fotos.length > 0" class="section">
            <h3>Fotos</h3>
            <div class="fotos-grid">
              <a v-for="(foto, i) in details.fotos" :key="i" :href="foto.url" target="_blank" class="foto">
                <img :src="foto.url" :alt="`Foto ${i + 1}`" />
              </a>
            </div>
          </section>

          <!-- Costo -->
          <section class="section costo-section">
            <p class="costo-text">💰 Costo de consulta: ${{ details.costo_usd.toFixed(4) }} USD</p>
          </section>
        </div>

        <!-- Sin detalles -->
        <div v-else class="empty">
          <p>Sin detalles disponibles</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from "vue"

interface PlaceDetails {
  nombre: string
  direccion: string
  telefono?: string
  website?: string
  url_google: string
  rating?: number
  horarios: string[]
  abierto_ahora?: boolean
  fotos: Array<{ url: string; atribucion?: string }>
  reviews: Array<{ autor: string; rating: number; fecha: string; texto: string }>
  tipos: string[]
  costo_usd: number
}

const props = defineProps({
  isOpen: Boolean,
  prospect: {
    type: Object,
    required: true,
  },
})

const emit = defineEmits(["close"])

const loading = ref(false)
const error = ref("")
const details = ref<PlaceDetails | null>(null)

watch(
  () => props.isOpen,
  (newVal) => {
    if (newVal && !details.value) {
      fetchDetails()
    }
  }
)

async function fetchDetails() {
  loading.value = true
  error.value = ""

  try {
    const response = await fetch(
      `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/get-place-details`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          apikey: import.meta.env.VITE_SUPABASE_ANON_KEY,
        },
        body: JSON.stringify({
          place_id: props.prospect.google_places_id,
          prospect_id: props.prospect.id,
          usuario_id: props.prospect.usuario_id,
          business_name: props.prospect.nombre,
          address: props.prospect.dirección,
        }),
      }
    )

    if (!response.ok) {
      throw new Error(`Error: ${response.statusText}`)
    }

    const data = await response.json()
    details.value = data
  } catch (e: any) {
    error.value = e.message || "Error al cargar detalles"
    console.error("Error fetching details:", e)
  } finally {
    loading.value = false
  }
}

function close() {
  emit("close")
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: var(--ink-2);
  border-radius: 12px;
  border: 1px solid var(--line);
  max-width: 600px;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid var(--line);
  position: sticky;
  top: 0;
  background: var(--ink-2);
  z-index: 10;
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  color: var(--text);
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--text-muted);
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition: all 150ms;
}

.close-btn:hover {
  background: rgba(255, 159, 67, 0.1);
  color: var(--orange);
}

.modal-body {
  padding: 24px;
}

.loading,
.error-box,
.empty {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-muted);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var(--line);
  border-top-color: var(--orange);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-box {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid var(--error);
  border-radius: 8px;
  padding: 20px;
  color: var(--error);
}

.section {
  margin-bottom: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid var(--line);
}

.section:last-of-type {
  border-bottom: none;
  margin-bottom: 0;
}

.section h3 {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  margin: 0 0 16px;
  letter-spacing: 0.05em;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.label {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
}

.value {
  font-size: 14px;
  color: var(--text);
}

.value a {
  color: var(--orange);
  text-decoration: none;
  transition: all 150ms;
}

.value a:hover {
  text-decoration: underline;
}

.muted {
  color: var(--text-muted);
  font-style: italic;
}

.horarios {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.horario-item {
  padding: 8px 12px;
  background: var(--ink-1);
  border-radius: 6px;
  font-size: 13px;
  color: var(--text);
}

.estado {
  padding: 8px 12px;
  border-radius: 6px;
  font-weight: 600;
  font-size: 13px;
}

.estado.abierto {
  background: rgba(34, 197, 94, 0.1);
  color: #22c55e;
}

.estado.cerrado {
  background: rgba(239, 68, 68, 0.1);
  color: var(--error);
}

.enlaces {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.link {
  padding: 12px;
  background: var(--ink-1);
  border-radius: 6px;
  color: var(--orange);
  text-decoration: none;
  transition: all 150ms;
  font-size: 14px;
}

.link:hover {
  background: rgba(255, 159, 67, 0.1);
  transform: translateX(4px);
}

.rating {
  padding: 12px;
  background: var(--ink-1);
  border-radius: 6px;
  display: inline-block;
}

.stars {
  font-size: 16px;
  color: var(--orange);
  font-weight: 600;
}

.reviews {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.review-item {
  padding: 12px;
  background: var(--ink-1);
  border-radius: 6px;
  border-left: 3px solid var(--orange);
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.review-author {
  font-weight: 600;
  color: var(--text);
  font-size: 13px;
}

.review-rating {
  font-size: 12px;
  color: var(--orange);
}

.review-date {
  display: block;
  font-size: 11px;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.review-text {
  font-size: 13px;
  color: var(--text);
  line-height: 1.5;
  margin: 0;
}

.fotos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.foto {
  overflow: hidden;
  border-radius: 8px;
  cursor: pointer;
  transition: all 200ms;
}

.foto:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.foto img {
  width: 100%;
  height: 120px;
  object-fit: cover;
  display: block;
}

.costo-section {
  background: var(--ink-1);
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid var(--line);
  margin: 0;
  padding-bottom: 0;
}

.costo-text {
  margin: 0;
  font-size: 12px;
  color: var(--text-muted);
  font-style: italic;
}

@media (max-width: 768px) {
  .modal-overlay {
    padding: 0;
  }

  .modal-content {
    max-width: 100%;
    max-height: 100vh;
    border-radius: 0;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }
}
</style>
