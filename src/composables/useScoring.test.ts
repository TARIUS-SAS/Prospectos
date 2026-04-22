import { describe, it, expect, vi } from 'vitest'

describe('useScoring', () => {
  it('debería calcular score correctamente (sin website)', async () => {
    const supabaseMock = {
      callEdgeFunction: vi.fn().mockResolvedValue({
        score: 10,
        desglose: { sin_website: 10 },
        es_caliente: false,
      }),
    }

    const prospect = {
      nombre: 'Café Central',
      website: null,
      sri_activo: false,
    }

    const result = await supabaseMock.callEdgeFunction('calculate-score', prospect)

    expect(result.score).toBe(10)
    expect(result.desglose.sin_website).toBe(10)
    expect(result.es_caliente).toBe(false)
  })

  it('debería marcar como "caliente" si score >= 15', async () => {
    const supabaseMock = {
      callEdgeFunction: vi.fn().mockResolvedValue({
        score: 16,
        desglose: { sin_website: 10, sri_activo: 3, tiene_teléfono: 2, zona_comercial: 2 },
        es_caliente: true,
      }),
    }

    const prospect = {
      nombre: 'Farmacia Premium',
      website: null,
      sri_activo: true,
      teléfono: '0987654321',
      zona: 'Centro',
    }

    const result = await supabaseMock.callEdgeFunction('calculate-score', prospect)

    expect(result.score).toBeGreaterThanOrEqual(15)
    expect(result.es_caliente).toBe(true)
  })

  it('debería propagar errores de Edge Function', async () => {
    const supabaseMock = {
      callEdgeFunction: vi.fn().mockRejectedValue(new Error('Edge Function error')),
    }

    const prospect = { nombre: 'Test' }

    await expect(
      supabaseMock.callEdgeFunction('calculate-score', prospect)
    ).rejects.toThrow('Edge Function error')
  })
})
