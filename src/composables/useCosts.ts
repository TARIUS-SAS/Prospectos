import { ref } from 'vue'
import { useSupabase } from './useSupabase'
import { useAuth } from './useAuth'

export interface CostBreakdown {
  costoSearchReal: number
  costoSearchVenta: number
  costoEmpresasReal: number
  costoEmpresasVenta: number
  costoTotalReal: number
  costoTotalVenta: number
  margenAbsoluto: number
  margenPorcentaje: number
}

const adminSettings = ref<Record<string, number>>({})

export function useCosts() {
  const supabase = useSupabase()
  const auth = useAuth()

  async function loadAdminSettings() {
    const { data } = await supabase.client
      .from('admin_settings')
      .select('clave, valor')

    if (data) {
      data.forEach((setting: any) => {
        adminSettings.value[setting.clave] = parseFloat(setting.valor)
      })
    }
  }

  async function getPlanCosts() {
    const { data: userPlan } = await supabase.client
      .from('user_subscriptions')
      .select('billing_plans(costo_búsqueda_venta, costo_empresa_venta, costo_guardado_venta)')
      .eq('usuario_id', auth.user.value?.id)
      .eq('estado', 'activo')
      .maybeSingle()

    if (userPlan?.billing_plans) {
      return {
        búsqueda: userPlan.billing_plans.costo_búsqueda_venta,
        empresa: userPlan.billing_plans.costo_empresa_venta,
        guardado: userPlan.billing_plans.costo_guardado_venta,
      }
    }

    const { data: starterPlan } = await supabase.client
      .from('billing_plans')
      .select('costo_búsqueda_venta, costo_empresa_venta, costo_guardado_venta')
      .eq('nombre', 'Starter')
      .single()

    return {
      búsqueda: starterPlan?.costo_búsqueda_venta ?? 0.50,
      empresa: starterPlan?.costo_empresa_venta ?? 0.05,
      guardado: starterPlan?.costo_guardado_venta ?? 0.10,
    }
  }

  function calculateSearchCost(
    cantidadEmpresas: number,
    cantidadFiltros: number
  ): number {
    const costoBase = 0.30
    const costoPorFiltro = 0.05
    const costoPorEmpresa = 0.05

    return costoBase + (cantidadFiltros * costoPorFiltro) + (cantidadEmpresas * costoPorEmpresa)
  }

  function calculateMargin(costoReal: number, costoVenta: number): CostBreakdown {
    const margenAbsoluto = costoVenta - costoReal
    const margenPorcentaje = (margenAbsoluto / costoVenta) * 100

    return {
      costoSearchReal: 0,
      costoSearchVenta: 0,
      costoEmpresasReal: costoReal,
      costoEmpresasVenta: costoVenta,
      costoTotalReal: costoReal,
      costoTotalVenta: costoVenta,
      margenAbsoluto,
      margenPorcentaje: Math.round(margenPorcentaje * 100) / 100,
    }
  }

  return {
    adminSettings,
    loadAdminSettings,
    getPlanCosts,
    calculateSearchCost,
    calculateMargin,
  }
}
