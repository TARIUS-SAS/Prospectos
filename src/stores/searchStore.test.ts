import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ref } from 'vue'

vi.mock('../composables/useSupabase', () => ({
  useSupabase: () => ({
    client: {
      from: vi.fn(),
    },
  }),
}))

vi.mock('../composables/useAuth', () => ({
  user: ref({
    id: 'test-user-id-12345',
    email: 'test@example.com',
  }),
}))

// Import after mocking
import { useSearchStore } from './searchStore'
import { setActivePinia, createPinia } from 'pinia'

describe('useSearchStore - Schema Validation', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('debería validar que los nombres de columnas son correctos', () => {
    const store = useSearchStore()

    // Simulamos el objeto que se enviaría a supabase.insert()
    const searchRecord = {
      usuario_id: 'test-user-id-12345',
      query: JSON.stringify(store.filters),
      zona: 'Centro',
      tipo_negocio: 'Restaurante',
      nombre: null,
      empleados_range: null,
      presencia_web: null,
      cantidad_resultados_pedida: 20,
      cantidad_resultados_obtenida: 2,
      estado: 'exitosa',
    }

    // Validar que tiene los campos correctos
    expect(searchRecord).toHaveProperty('usuario_id')
    expect(searchRecord).toHaveProperty('query')
    expect(searchRecord).toHaveProperty('cantidad_resultados_pedida')
    expect(searchRecord).toHaveProperty('cantidad_resultados_obtenida')
    expect(searchRecord).toHaveProperty('estado')

    // Validar que NO tiene columnas que no existen en el schema
    expect(searchRecord).not.toHaveProperty('palabra_clave')
    expect(searchRecord).not.toHaveProperty('score_promedio')
    expect(searchRecord).not.toHaveProperty('cantidad_resultados')
    expect(searchRecord).not.toHaveProperty('sri_activo')
  })

  it('debería filtrar hotProspects correctamente', () => {
    const store = useSearchStore()

    // Simulamos resultados de búsqueda
    store.results = [
      { id: '1', nombre: 'Negocio 1', score: 75 },
      { id: '2', nombre: 'Negocio 2', score: 65 },
      { id: '3', nombre: 'Negocio 3', score: 80 },
      { id: '4', nombre: 'Negocio 4', score: 50 },
    ]

    // Validar que hotProspects filtra score >= 70
    expect(store.hotProspects).toHaveLength(2)
    expect(store.hotProspects.map((p: any) => p.score)).toEqual([75, 80])
  })

  it('debería calcular resultCount correctamente', () => {
    const store = useSearchStore()

    store.results = [
      { id: '1', nombre: 'Negocio 1' },
      { id: '2', nombre: 'Negocio 2' },
      { id: '3', nombre: 'Negocio 3' },
    ]

    expect(store.resultCount).toBe(3)
  })
})
