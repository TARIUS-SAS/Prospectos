# INSTRUCCIONES PARA IA - DISEÑO FRONTEND PROSPECTOR WEB

## OBJETIVO
Diseñar y desarrollar un **frontend profesional, minimalista y funcional** para Prospector Web siguiendo el tema **Dark Navy + Orange** (similar a Almacenes Point).

---

## ENTREGA ESPERADA

### Opción A: Código Vue.js (RECOMENDADO)
- Todos los archivos `.vue` listos para reemplazar en `src/`
- Componentes reutilizables en `src/components/`
- Vistas completas en `src/views/`
- Estilos en `src/styles/globals.css`
- Compatible con Tailwind CSS v4

### Opción B: Diseño Figma
- Wireframes de todas las 8 vistas
- Componentes especificados
- Paleta de colores y tipografía definida
- Spacing y layout detallado

---

## ESPECIFICACIONES DE DISEÑO

### Paleta de Colores
```
Primario:           #ff9f43 (Orange - CTAs, números, acentos)
Fondo principal:    #2c3e50 (Navy oscuro)
Fondo secundario:   #1e2d3d (Navy más oscuro - sidebar)
Border/Line:        #3a4f63 (Navy semi-transparente)
Texto principal:    #e8e8e8 (Gris claro)
Texto secundario:   #b0b0b0 (Gris medio)
Éxito:              #00d084 (Verde)
Error:              #ff6b6b (Rojo)
Warning:            #ffa940 (Ámbar)
Info:               #1890ff (Azul)
```

### Tipografía
```
Display/Headings:   Inter Bold 700, tamaño 24-32px
Body/Texto:         Inter Regular 400, tamaño 14-16px
Labels:             Inter Medium 500, tamaño 12-14px
```

### Iconografía
- Usar emojis simples o Lucide Vue (para consistency)
- Tamaños: 16px (pequeño), 20px (normal), 24px (grande), 32px (decorativo)

### Espaciado (Tailwind)
```
xs: 8px
sm: 12px
md: 16px
lg: 24px
xl: 32px
```

### Componentes Base
Todos deben tener `data-testid` para testing posterior:
- Button (primary, secondary, danger) con estados (hover, active, disabled)
- Input (text, email, password, number)
- Dropdown / Select
- Card (simple, con border)
- Modal / Dialog
- Toast / Notification
- Badge / Pill (para estados)
- Icon (wrapper para iconos)
- Loading Spinner
- Empty State

---

## VISTAS A DISEÑAR (8 TOTAL)

### 1. LOGIN VIEW (`/login`)
**Tipo:** Full-screen, centrado
**Contenido:**
- Logo circular (orange, tamaño 64px)
- Título "PROSPECTOR"
- Subtítulo "Busca clientes sin presencia web"
- Form:
  - Input email
  - Input password
  - Botón "ENTRAR" (primary)
  - Link "Contacta a Tarius SAS"
- Error message (si aplica)
- Sin sidebar

**Mockup mental:**
```
┌─────────────────────────────┐
│                             │
│         [Logo 🔍]           │
│      PROSPECTOR             │
│  Busca clientes sin web    │
│                             │
│  ┌──────────────────────┐   │
│  │ Email...             │   │
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ Contraseña...        │   │
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ ENTRAR               │   │ (orange bg)
│  └──────────────────────┘   │
│                             │
│ ¿No tienes cuenta?          │
│ Contacta a Tarius SAS       │
│                             │
└─────────────────────────────┘
```

---

### 2. DASHBOARD VIEW (`/dashboard`)
**Tipo:** Con sidebar izquierdo
**Contenido:**
- Header:
  - "Operación / Hoy" (breadcrumb)
  - Título "Dashboard"
  - Reloj en tiempo real (hh:mm)
  - Ciudad "GUAYAQUIL"

- Grid de 6 cards (métricas):
  - Total búsquedas
  - Empresas
  - Guardados
  - Compromisos
  - Costo hoy
  - Costo mes
  - (Números grandes en orange)

- Sección "Tanda actual":
  - Badge verde "● TANDA 1 EN CURSO"
  - 3 items con hora
  - Tanda 3 con color green

- Sección "Mi plan":
  - Plan name ("Starter")
  - Búsquedas disponibles (17/20)
  - Botón "Cambiar plan"

**Mockup:**
```
┌────────────────┬──────────────────────────────────────┐
│ [Logo]         │ Operación / Hoy              hh:mm   │
│ PROSPECTOR     │ Dashboard                   GUAYAQUIL│
│ Pro            │                                      │
│                │ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐      │
│ • Dashboard    │ │0 │ │0 │ │0 │ │0 │ │$0│ │$0│      │
│ • Nueva búsq   │ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘      │
│ • Mis búsq     │                                      │
│ • Guardados    │ ┌──────────────┐ ┌──────────────┐   │
│ • Config       │ │ Tanda actual │ │ Mi plan      │   │
│ • Admin        │ │ ● EN CURSO   │ │ Starter      │   │
│                │ │ • Tanda 1    │ │ 17/20        │   │
│ ● Sistema act. │ │   9:30 AM    │ │ [Cambiar]    │   │
│ Prospector     │ │ • Tanda 2    │ │              │   │
│                │ │   2:30 PM    │ └──────────────┘   │
│                │ │ • Tanda 3 🟢 │                     │
│                │ │   5:00 PM    │                     │
│                │ └──────────────┘                     │
└────────────────┴──────────────────────────────────────┘
```

---

### 3. SEARCH VIEW (`/search`)
**Tipo:** Con sidebar
**Contenido:**
- Header similar al dashboard
- Card de búsqueda con:
  - 5 dropdowns (zona, tipo negocio, nombre, empleados, presencia web)
  - Card de costo estimado (con icono 💰)
  - Input cantidad resultados + Botón "BUSCAR" (orange)
  - Botón "Limpiar filtros"

- Resultados (debajo):
  - Loading spinner (si está buscando)
  - Grid de cards con prospectos:
    - Nombre
    - Dirección
    - Teléfono (link tel:)
    - Score (orange si es caliente, gris si no)
    - Badge "🔥 CALIENTE" (si aplica)
  - Empty state si no hay resultados
  - Error message si falla

---

### 4. PROSPECT DETAIL VIEW (`/prospect/:id`)
**Tipo:** Con sidebar
**Contenido:**
- Header: nombre, dirección, score (grande)
- Tabs: Actual, Anterior, Comparación
- Tab Actual:
  - Grid 2x2 de datos:
    - Contacto (tel)
    - Website (con https indicator)
    - SRI (estado)
    - Rating (⭐)
  - Sección "Desglose de score" (tabla)
  - Botón "Actualizar datos ($0.10)"
  - Botones: "Guardar", "Eliminar"

---

### 5. HISTORY VIEW (`/history`)
**Tipo:** Con sidebar
**Contenido:**
- Header: "Mis búsquedas"
- Lista de cards:
  - Query (búsqueda realizada)
  - Cantidad resultados
  - Fecha
  - Costo (orange)
  - Botón "Ver resultados"
- Empty state si no hay búsquedas

---

### 6. SAVED VIEW (`/saved`)
**Tipo:** Con sidebar
**Contenido:**
- Header: "Prospectos guardados"
- Dropdown: "Filtrar por estado"
- Grid de cards con prospectos:
  - Nombre
  - Dirección
  - Score
  - Estado (badge)
  - Notas (si existen)
  - Botones: "Ver detalle", cambio de estado

---

### 7. ADMIN VIEW (`/admin`)
**Tipo:** Con sidebar (solo si user.isAdmin)
**Contenido:**
- 3 cards de stats (Costo real, Ingresos, Margen %)
- 3 tabs: Usuarios, Facturación, Configuración
- Tab Usuarios: Grid de users con plan y consumo
- Tab Facturación: Placeholder ("En desarrollo")
- Tab Configuración: Inputs para costos operacionales

---

### 8. SETTINGS VIEW (`/settings`)
**Tipo:** Con sidebar
**Contenido:**
- Sección "Cuenta":
  - Email (readonly)
  - Plan actual
  - Botón "Cambiar plan"
- Sección "Preferencias":
  - Input búsquedas máximas/día
  - Input resultados por defecto
  - Botón "Guardar"
- Sección "Seguridad":
  - Botón "Cambiar contraseña"

---

## SIDEBAR (NAVEGACIÓN IZQUIERDA)

**Ancho:** 256px (w-64)
**Fondo:** #1e2d3d
**Contenido:**

```
┌─────────────────────────────┐
│ [Logo] PROSPECTOR           │
│        Pro                  │
├─────────────────────────────┤
│ 📊 Dashboard                │
│ 🔍 Nueva búsqueda           │
│ 📂 Mis búsquedas            │
│ 💾 Guardados                │
│ ⚙️  Configuración            │
│ 🔐 Admin                    │
│                             │
├─────────────────────────────┤
│ ● Sistema activo            │
│ Prospector en tiempo real   │
└─────────────────────────────┘
```

**Item activo:** Tiene border-left orange y fondo subtle

---

## COMPONENTES ESPECÍFICOS

### Button Component
```vue
<!-- Uso -->
<Button variant="primary|secondary|danger" size="sm|md|lg" :disabled="false">
  Texto
</Button>

<!-- Estilos -->
primary:   bg-orange text-dark hover:bg-orange/90
secondary: bg-darker border-border text-text hover:bg-dark
danger:    bg-error text-white hover:bg-error/90
```

### Card Component
```vue
<Card>
  <!-- Contenido -->
</Card>

<!-- Estilos -->
bg: #1e2d3d
border: 1px solid #3a4f63
padding: 24px
border-radius: 8px
```

### Badge/Pill Component
```vue
<Badge variant="success|error|warning|info" size="sm|md">
  Texto
</Badge>
```

### Input Component
```vue
<Input
  v-model="value"
  type="text|email|password|number"
  label="Label"
  placeholder="..."
  :error="errorText"
/>

<!-- Focus state: border-orange, shadow con orange -->
```

---

## RESPONSIVIDAD

**Breakpoints (Tailwind v4):**
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px

**Estrategia:**
- **Mobile:** Cards apiladas, sidebar se convierte en drawer (oculto por defecto)
- **Tablet:** 2 columnas en grids, sidebar visible si espacio
- **Desktop:** Layout completo con sidebar visible

---

## ANIMACIONES Y TRANSICIONES

**Restricciones:**
- Duración: 200-300ms máximo
- Easing: `ease-out`
- Sin animaciones complejas (spring, rotación)
- Transiciones simples: opacity, color, shadow

**Ejemplos:**
```css
hover:     opacity transition 200ms
focus:     border-color + shadow transition 200ms
active:    scale-95 transition 100ms
disabled:  opacity 50%
loading:   spinner (CSS animation simple)
```

---

## VALIDACIÓN Y ESTADOS

**Input states:**
- `default`: border gris
- `focus`: border orange, shadow
- `error`: border rojo, text rojo
- `disabled`: bg gris, cursor not-allowed

**Button states:**
- `default`: color primary
- `hover`: bg intenso
- `active`: scale 95%
- `disabled`: opacity 50%, cursor not-allowed
- `loading`: spinner inside button

---

## ACCESIBILIDAD

**Requisitos:**
- [ ] Contraste WCAG AA mínimo (4.5:1 para texto normal)
- [ ] Focus states visibles (outline o border)
- [ ] Keyboard navigation (Tab, Enter, Escape)
- [ ] ARIA labels donde sea necesario
- [ ] `data-testid` en elementos interactivos

---

## ARCHIVOS A ENTREGAR

Si haces código Vue.js:

```
src/
├── components/
│   ├── common/
│   │   ├── Button.vue
│   │   ├── Input.vue
│   │   ├── Card.vue
│   │   ├── Modal.vue
│   │   ├── Toast.vue
│   │   ├── Dropdown.vue
│   │   ├── Badge.vue
│   │   ├── LoadingSpinner.vue
│   ├── layout/
│   │   ├── Sidebar.vue
│   │   ├── Header.vue
│   ├── ProspectCard.vue
│   ├── StatCard.vue
│   ├── SearchForm.vue
│   ├── ProspectList.vue
│   ├── EmptyState.vue
│
├── views/
│   ├── LoginView.vue
│   ├── DashboardView.vue
│   ├── SearchView.vue
│   ├── ProspectDetailView.vue
│   ├── HistoryView.vue
│   ├── SavedView.vue
│   ├── AdminView.vue
│   ├── SettingsView.vue
│
├── styles/
│   ├── globals.css (con tokens, keyframes, utilidades)
│   ├── index.css
│
├── App.vue (actualizado con layout sidebar)
```

---

## INSTRUCCIONES DE INTEGRACIÓN

1. **Reemplaza carpetas:**
   - `src/components/` → archivos nuevos
   - `src/views/` → archivos nuevos
   - `src/styles/globals.css` → archivo nuevo

2. **Actualiza App.vue:**
   - Importa Sidebar
   - Condiciona visibilidad si `authStore.user`

3. **Verifica:**
   - `npm run dev` compila sin errores
   - Todas las vistas son accesibles
   - Sidebar aparece cuando está logueado
   - Login se ve bien sin sidebar

4. **Test:**
   - Responsividad: mobile, tablet, desktop
   - Todos los estados (hover, focus, disabled, loading)
   - Navegación entre vistas funciona

---

## NOTAS FINALES

- **Minimalismo:** Sin decoraciones innecesarias, enfoque en funcionalidad
- **Profesionalismo:** Tema oscuro es premium, orange es acción
- **Consistencia:** Todos los componentes usan la misma paleta y spacing
- **Velocidad:** CSS puro, sin JS pesado en animaciones
- **Mantenibilidad:** Código limpio, componentes reutilizables, sin hard-coded values

---

**Última actualización:** 2026-04-22  
**Proyecto:** Prospector Web  
**Stack:** Vue 3 + Tailwind CSS v4 + TypeScript
