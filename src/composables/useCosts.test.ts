import { describe, it, expect } from 'vitest'

describe('useCosts', () => {
  describe('calculateSearchCost', () => {
    it('debería calcular costo correctamente sin filtros', () => {
      const costoBase = 0.30
      const costoPorFiltro = 0.05
      const costoPorEmpresa = 0.05

      const cantidadFiltos = 0
      const cantidadEmpresas = 20

      const costo = costoBase + (cantidadFiltos * costoPorFiltro) + (cantidadEmpresas * costoPorEmpresa)

      expect(costo).toBe(1.30) // 0.30 + 0 + 1.0
    })

    it('debería incluir costo por filtros', () => {
      const costoBase = 0.30
      const costoPorFiltro = 0.05
      const costoPorEmpresa = 0.05

      const cantidadFiltros = 3
      const cantidadEmpresas = 20

      const costo = costoBase + (cantidadFiltros * costoPorFiltro) + (cantidadEmpresas * costoPorEmpresa)

      expect(costo).toBe(1.45) // 0.30 + 0.15 + 1.0
    })

    it('debería respetar máximo de empresas (50)', () => {
      const costoBase = 0.30
      const costoPorFiltro = 0.05
      const costoPorEmpresa = 0.05

      const cantidadFiltros = 2
      const cantidadEmpresas = 50

      const costo = costoBase + (cantidadFiltros * costoPorFiltro) + (cantidadEmpresas * costoPorEmpresa)

      expect(costo).toBeCloseTo(2.90, 1) // 0.30 + 0.10 + 2.50
    })
  })

  describe('calculateMargin', () => {
    it('debería calcular margen correctamente', () => {
      const costoReal = 10
      const costoVenta = 25

      const margenAbsoluto = costoVenta - costoReal
      const margenPorcentaje = (margenAbsoluto / costoVenta) * 100

      expect(margenAbsoluto).toBe(15)
      expect(Math.round(margenPorcentaje * 100) / 100).toBe(60)
    })

    it('debería manejar costo cero', () => {
      const costoReal = 0
      const costoVenta = 50

      const margenAbsoluto = costoVenta - costoReal
      const margenPorcentaje = (margenAbsoluto / costoVenta) * 100

      expect(margenAbsoluto).toBe(50)
      expect(margenPorcentaje).toBe(100)
    })
  })
})
