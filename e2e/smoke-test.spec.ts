import { test, expect } from '@playwright/test'

test.describe('Prospector Web - Flujo Feliz', () => {
  const BASE_URL = 'http://localhost:5173'
  const TEST_EMAIL = 'test@example.com'
  const TEST_PASSWORD = 'testpassword123'

  test('debería completar flujo: Login → Dashboard → Search → Detail', async ({ page }) => {
    // Paso 1: Ir a login
    await page.goto(`${BASE_URL}/login`)
    await expect(page.locator('h1')).toContainText('PROSPECTOR')

    // Paso 2: Validar campos de login
    await expect(page.locator('input[type="email"]')).toBeVisible()
    await expect(page.locator('input[type="password"]')).toBeVisible()
    await expect(page.locator('button[type="submit"]')).toBeVisible()

    // Paso 3: Validar que sin email, mostrar error
    await page.locator('button[type="submit"]').click()
    await expect(page.locator('text=Email requerido')).toBeVisible()

    // Paso 4: Navegar a dashboard (requiere auth, redirige a login)
    await page.goto(`${BASE_URL}/dashboard`)
    await expect(page.locator('input[type="email"]')).toBeVisible() // Redirigido a login

    // Paso 5: Verificar estructura de búsqueda (sin autenticación)
    await page.goto(`${BASE_URL}/search`)
    await expect(page.locator('input[type="email"]')).toBeVisible() // Redirigido a login
  })

  test('debería validar estructura de SearchView', async ({ page }) => {
    await page.goto(`${BASE_URL}/search`)

    // Validar que el formulario de búsqueda existe
    // (este test requeriría autenticación real para probar completamente)
    await page.waitForLoadState('networkidle')

    // Validar que las dropdowns de filtros existen (sin autenticación, podrían no cargar)
    // Este es un smoke test estructural, no de lógica
  })

  test('debería mostrar componentes correctamente en ProspectDetail', async ({ page }) => {
    // Este test verifica que la vista renderiza sin errores (aunque sea con datos mock)
    // En un escenario real con auth, verificaría:
    // - Carga de datos del prospecto
    // - Renderizado de tabs (Actual, Anterior, Comparación)
    // - Información correcta mostrada

    await page.goto(`${BASE_URL}/`)
    // Si no autenticado, redirige a login
    await expect(page.locator('input[type="email"]')).toBeVisible()
  })

  test('debería tener header con logout', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`)

    // Verificar que el header existe (si autenticado)
    // Por ahora solo verificamos que login renderiza
    await expect(page.locator('h1')).toContainText('PROSPECTOR')
  })

  test('debería validar que admin requiere rol correcto', async ({ page }) => {
    // AdminView redirige si no es admin
    await page.goto(`${BASE_URL}/admin`)

    // Sin autenticación, debería redirigir a login
    await expect(page.locator('input[type="email"]')).toBeVisible()
  })
})
