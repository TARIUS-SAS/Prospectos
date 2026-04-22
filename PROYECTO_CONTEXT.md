# PROSPECTOR WEB - CONTEXTO COMPLETO DEL PROYECTO

## 1. DESCRIPCIÓN GENERAL

**Prospector Web** es una herramienta SaaS de prospección B2B para Ecuador que identifica comercios pequeños y medianos sin presencia web y genera listas priorizadas por score de prospecto.

**Usuarios:**
- Admin principal (Mateo, fundador Tarius SAS)
- Colaboradores (acceso a sus propias búsquedas y prospectos)

**Objetivo:** Automatizar búsqueda de clientes potenciales para servicios de diseño web

---

## 2. STACK TECNOLÓGICO

```
Frontend:
- Vue 3 + Vite
- TypeScript
- Composition API + <script setup>
- Pinia (estado global)
- Vue Router 4
- Tailwind CSS v4

Backend/DB:
- Supabase (PostgreSQL + Auth + Edge Functions)
- Row Level Security (RLS)

APIs Externas:
- Google Places API (búsqueda de negocios)
- SRI Ecuador (consulta pública de RUC)

Hosting:
- Vercel (frontend)

Idioma:
- Español (Ecuador)
```

---

## 3. ESTRUCTURA DE CARPETAS

```
prospector-web/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.vue
│   │   │   ├── Input.vue
│   │   │   ├── Card.vue
│   │   │   ├── Modal.vue
│   │   │   ├── Toast.vue
│   │   │   ├── Dropdown.vue
│   │   ├── layout/
│   │   │   ├── Header.vue
│   │   │   ├── Sidebar.vue
│   │   ├── GradientNumber.vue
│   │   ├── CheckAnimation.vue
│   │   ├── WaveSeparator.vue
│   │   ├── AsymmetricCard.vue
│   │   ├── StatCard.vue
│   ├── views/
│   │   ├── LoginView.vue
│   │   ├── DashboardView.vue
│   │   ├── SearchView.vue
│   │   ├── ProspectDetailView.vue
│   │   ├── HistoryView.vue
│   │   ├── SavedView.vue
│   │   ├── AdminView.vue
│   │   ├── SettingsView.vue
│   ├── stores/
│   │   ├── authStore.ts
│   │   ├── costStore.ts
│   ├── composables/
│   │   ├── useSupabase.ts
│   │   ├── useAuth.ts
│   │   ├── useCosts.ts
│   ├── services/
│   │   ├── supabaseClient.ts
│   ├── utils/
│   │   ├── colorTokens.ts
│   │   ├── scoring.ts
│   ├── styles/
│   │   ├── globals.css
│   │   ├── index.css
│   ├── App.vue
│   ├── main.ts
├── supabase/
│   ├── migrations/
│   │   ├── 20260422_create_billing_plans.sql
│   │   ├── 20260422_create_users_metadata.sql
│   │   ├── 20260422_create_prospects.sql
│   │   ├── 20260422_create_prospect_versions.sql
│   ├── functions/
├── .env (NO COMMITEAR)
├── .env.example
├── tailwind.config.ts
├── vite.config.ts
├── tsconfig.json
├── package.json
└── CLAUDE.md (instrucciones del proyecto)
```

---

## 4. RUTAS Y VISTAS

```typescript
/login              → LoginView.vue (sin sidebar)
/dashboard          → DashboardView.vue (home, stats)
/search             → SearchView.vue (nueva búsqueda)
/history            → HistoryView.vue (búsquedas realizadas)
/saved              → SavedView.vue (prospectos guardados)
/prospect/:id       → ProspectDetailView.vue (detalle de prospecto)
/settings           → SettingsView.vue (configuración usuario)
/admin              → AdminView.vue (dashboard admin)
/                   → Redirige a /dashboard o /login
```

---

## 5. VISTAS PRINCIPALES Y FUNCIONALIDAD

### 5.1 LoginView
**URL:** `/login`
**Función:** Autenticación de usuarios
**Componentes:**
- Inputs para email/contraseña
- Botón login
- Link "Contacta a Tarius SAS"

**Datos:** Integración con Supabase Auth

---

### 5.2 DashboardView
**URL:** `/dashboard`
**Función:** Página de inicio con resumen y acciones rápidas
**Componentes:**
- Header con hora actual y operador
- Grid de 6 cards con métricas:
  - Total búsquedas (hoy)
  - Empresas encontradas
  - Guardados
  - Compromisos
  - Costo hoy
  - Costo mes
- Sección "Tanda actual" (horarios de búsqueda)
- Sección "Mi plan" (Starter con 17/20 búsquedas disponibles)

**Datos:**
```typescript
{
  búsquedas_hoy: 0,
  empresas_encontradas: 0,
  guardados: 0,
  compromisos: 0,
  costo_hoy: $0.00,
  costo_mes: $0.00,
  plan: "Starter",
  búsquedas_disponibles: 17,
  tandas: [
    { numero: 1, hora: "9:30 AM", estado: "en_curso" },
    { numero: 2, hora: "2:30 PM", estado: "pendiente" },
    { numero: 3, hora: "5:00 PM", estado: "pendiente" }
  ]
}
```

---

### 5.3 SearchView
**URL:** `/search`
**Función:** Búsqueda avanzada de prospectos
**Componentes:**
- Filtros (dropdown):
  - Zona (Centro, Cumbayá, La Carolina, Quito Norte, Quito Sur)
  - Tipo de negocio (Café, Ferretería, Farmacia, etc.)
  - Nombre (text input)
  - Rango empleados (1-5, 5-20, 20-50, 50+)
  - Presencia web (Sin website, Solo redes, Website activo)
- Input: Cantidad de resultados (1-50)
- Card de costo estimado (dinámico)
- Botón Buscar
- Botón Limpiar filtros
- Grid de resultados (cards con nombre, dirección, teléfono, score)
- Loading spinner durante búsqueda
- Empty state si no hay resultados

**Datos:**
```typescript
{
  filtros: {
    zona: "Centro",
    tipo_negocio: "Café",
    nombre: "",
    empleados_range: "1-5",
    presencia_web: "sin_web"
  },
  cantidad_resultados: 20,
  costo_estimado: $0.50,
  resultados: [
    {
      id: "uuid",
      nombre: "Cafetería Mi Amor",
      dirección: "Calle Principal 123",
      teléfono: "+593 98 123 4567",
      website: null,
      https: false,
      sri_activo: true,
      google_rating: 4.2,
      score: 18,
      es_caliente: true
    }
  ]
}
```

---

### 5.4 ProspectDetailView
**URL:** `/prospect/:id`
**Función:** Detalle completo de un prospecto
**Componentes:**
- Header: Nombre, dirección, score en gradiente si es "caliente"
- Tabs: Actual, Anterior, Comparación
- Tab Actual:
  - Contacto (teléfono)
  - Website (con icono si tiene HTTPS)
  - SRI (estado)
  - Rating (⭐)
  - Desglose de score (tabla con puntos)
- Botón: Actualizar datos ($0.10)
- Botones: Guardar, Eliminar

**Datos:**
```typescript
{
  id: "uuid",
  nombre: "Negocio Ejemplo",
  dirección: "Dirección completa",
  teléfono: "+593 98 123 4567",
  website: "negocio.com",
  https: true,
  sri_activo: true,
  google_rating: 4.5,
  score: 24,
  es_caliente: true,
  desglose: {
    sin_website: 10,
    sri_activo: 3,
    tiene_teléfono: 2,
    zona_comercial: 2,
    redes_sociales: 5,
    https: 2
  }
}
```

---

### 5.5 HistoryView
**URL:** `/history`
**Función:** Historial de búsquedas realizadas
**Componentes:**
- Lista de cards con búsquedas anteriores
- Cada card muestra:
  - Query de búsqueda
  - Cantidad de resultados
  - Fecha
  - Costo
  - Botón "Ver resultados"

---

### 5.6 SavedView
**URL:** `/saved`
**Función:** Prospectos guardados/favoritos
**Componentes:**
- Dropdown para filtrar por estado
- Grid de cards con prospectos guardados
- Cada card muestra:
  - Nombre
  - Dirección
  - Score
  - Estado (Nuevo, Contactado, Interesado, Rechazado, Ganado)
  - Notas
  - Botones: Ver detalle, Cambiar estado

---

### 5.7 AdminView
**URL:** `/admin`
**Función:** Dashboard administrativo
**Componentes:**
- Stats cards:
  - Costo real (mes)
  - Ingresos (mes)
  - Margen bruto (%)
- Tabs: Usuarios, Facturación, Configuración
- Tab Usuarios: Lista de usuarios con plan y consumo
- Tab Facturación: Reporte de ingresos (placeholder)
- Tab Configuración:
  - Input: Costo Google Places por resultado
  - Input: Costo SRI por consulta
  - Botón: Guardar

---

### 5.8 SettingsView
**URL:** `/settings`
**Función:** Configuración del usuario
**Componentes:**
- Sección Cuenta:
  - Email (readonly)
  - Plan actual
  - Botón "Cambiar plan"
- Sección Preferencias de búsqueda:
  - Input: Búsquedas máximas por día
  - Input: Resultados por defecto
  - Botón: Guardar cambios
- Sección Seguridad:
  - Botón: Cambiar contraseña

---

## 6. PALETA DE COLORES ACTUAL (A MEJORAR)

**Tema:** Dark Navy + Orange Profesional

```css
/* Colores primarios */
--color-primary: #ff9f43;        /* Orange */
--color-dark: #2c3e50;           /* Navy oscuro (fondo) */
--color-darker: #1e2d3d;         /* Navy más oscuro (sidebar) */
--color-border: #3a4f63;         /* Border color */
--color-text: #e8e8e8;           /* Texto principal */
--color-text-secondary: #b0b0b0; /* Texto secundario */

/* Semánticos */
--color-success: #00d084;        /* Verde */
--color-error: #ff6b6b;          /* Rojo */
--color-warning: #ffa940;        /* Ámbar */
--color-info: #1890ff;           /* Azul */
```

---

## 7. SISTEMA DE SCORING (CÁLCULO PROSPECTO)

Puntaje de prospecto (0-24 puntos):

```typescript
const scoringRules = {
  sin_website: 10,           // No tiene website
  solo_redes: 7,             // Solo Facebook/Instagram
  website_sin_https: 5,      // Website pero sin HTTPS
  sri_activo: 3,             // Registrado en SRI
  tiene_teléfono: 2,         // Tiene teléfono
  zona_comercial: 2,         // En zona comercial (Centro, Cumbayá, etc.)
  redes_sociales: 5,         // Activo en redes
  https: 2                    // Website con HTTPS
}

prospecto.es_caliente = prospecto.score >= 15  // Marcar como "caliente" si score >= 15
```

---

## 8. ESQUEMA DE BASE DE DATOS (SUPABASE)

### Tablas principales:

**auth.users** (de Supabase)
```
id: uuid
email: string
password_hash: string
created_at: timestamp
```

**users_metadata**
```
id: uuid (referencia a auth.users)
búsquedas_max_por_día: int (default 20)
created_at: timestamp
updated_at: timestamp
```

**prospects**
```
id: uuid
nombre: string
dirección: string
teléfono: string
website: string (nullable)
https: boolean
sri_activo: boolean
google_rating: float
score: int (0-24)
es_caliente: boolean
usuario_id: uuid (RLS)
created_at: timestamp
updated_at: timestamp
```

**searches**
```
id: uuid
usuario_id: uuid (RLS)
query: string
filtros: jsonb
cantidad_resultados_obtenida: int
costo_total_real: decimal
costo_total_venta: decimal
timestamp: timestamp
```

**saved_prospects**
```
id: uuid
usuario_id: uuid (RLS)
prospect_id: uuid
estado: enum (Nuevo, Contactado, Interesado, Rechazado, Ganado)
notas: text (nullable)
created_at: timestamp
updated_at: timestamp
```

**billing_plans**
```
id: uuid
nombre: string (Starter, Professional, Enterprise)
descripción: text
búsquedas_por_mes: int
precio_monthly: decimal
created_at: timestamp
```

**user_subscriptions**
```
id: uuid
usuario_id: uuid (RLS)
plan_id: uuid (referencia a billing_plans)
estado: enum (activo, cancelado, suspendido)
fecha_inicio: date
fecha_fin: date (nullable)
created_at: timestamp
```

---

## 9. FLUJO DE AUTENTICACIÓN

```
1. Usuario va a /login
2. Ingresa email y contraseña
3. Supabase Auth valida credenciales
4. Si OK → token guardado en localStorage
5. Redirige a /dashboard
6. authStore.initAuth() en App.vue valida sesión activa
7. Si sesión invalida → redirige a /login
8. Logout → limpia token y sesión
```

---

## 10. FLUJO DE BÚSQUEDA (PROSPECTO)

```
1. Usuario va a /search
2. Llena filtros (zona, tipo negocio, etc.)
3. Elige cantidad de resultados
4. Haz clic en "Buscar"
5. Frontend calcula costo estimado
6. Envía request a Supabase Edge Function (search-google-places)
7. Edge Function:
   - Valida token
   - Llama Google Places API
   - Consulta SRI (RUC) para cada resultado
   - Calcula score usando reglas
   - Marca si es "caliente" (score >= 15)
   - Retorna resultados
8. Frontend muestra resultados en grid
9. Usuario puede:
   - Ver detalle de prospecto
   - Guardar prospecto
   - Contactar (copiar teléfono)
10. Búsqueda se registra en tabla "searches" para historial
```

---

## 11. RESTRICCIONES Y LÍMITES

```typescript
Rate Limiting:
- Máximo 20 búsquedas por usuario por día
- Máximo 50 resultados por búsqueda

Costos (por defecto):
- Google Places: $0.0034 por resultado
- SRI: $0.001 por consulta

Restricciones ARCOTEL (si se integra Retell):
- Horario: 8:00 AM - 8:00 PM
- Grabación: Informar al inicio
- Opt-out: Respetar si usuario pide no ser llamado
```

---

## 12. COMPONENTES REUTILIZABLES

```typescript
// Button.vue
<Button variant="primary|secondary" size="sm|md|lg" :disabled="false">
  Texto
</Button>

// Input.vue
<Input
  v-model="email"
  type="text|email|password|number"
  label="Label"
  placeholder="..."
  :error="errorMessage"
  :disabled="false"
/>

// Card.vue
<Card highlight="none|hot" class="...">
  <div>Contenido</div>
</Card>

// Modal.vue
<Modal
  v-model="isOpen"
  title="Confirmar"
  confirmText="OK"
  @confirm="handleConfirm"
>
  Contenido del modal
</Modal>

// Dropdown.vue
<Dropdown
  v-model="selected"
  label="Selecciona"
  :options="[{ value: 'a', label: 'Opción A' }]"
  :error="errorMessage"
/>

// Toast.vue
<Toast message="Guardado!" type="success|error|info" :duration="3000" />
```

---

## 13. ESTADO GLOBAL (PINIA)

```typescript
// authStore
- user: User | null
- isAuthenticated: boolean
- isAdmin: boolean
- login(email, password)
- logout()
- initAuth()

// costStore
- dailyCost: { búsquedas, empresas, guardados, total }
- monthlyCost: { búsquedas, empresas, guardados, total }
- updateDailyCost(data)
- updateMonthlyCost(data)
```

---

## 14. VARIABLES DE ENTORNO (.env)

```
VITE_SUPABASE_URL=https://fpfgjsxlnsofywlazrar.supabase.co
VITE_SUPABASE_ANON_KEY=<anon_key_aqui>

# Google Places Key: se configura en Supabase Edge Functions (NO en frontend)
# SRI: API pública, sin credenciales necesarias
```

---

## 15. COMANDOS IMPORTANTES

```bash
npm run dev              # Desarrollo local (localhost:5173)
npm run build           # Build producción
npm run lint            # ESLint
npm run test            # Tests (cuando se agreguen)

# Supabase
supabase start          # Local (si se configura)
supabase migrations     # Ver migraciones
supabase push           # Sincronizar cambios a producción
```

---

## 16. REQUISITOS DE DISEÑO (PARA LA IA)

**Tema:** Dark Navy + Orange Profesional (similar a Almacenes Point)

**Características:**
- Dark mode: Fondo #2c3e50, elementos más oscuros #1e2d3d
- Orange primario: #ff9f43 para CTAs y números
- Verde éxito: #00d084
- Sidebar izquierdo en navegación principal
- Cards simples con borders oscuros
- Números grandes y destacados en orange
- Tipografía sans-serif clara (Inter o similar)
- Sin animaciones complejas, funcional y limpio
- Responsive: mobile, tablet, desktop
- Accesibilidad: contraste, focus states, keyboard navigation

**Prioridades visuales:**
1. Claridad de datos (números, stats)
2. Facilidad de acción (botones, links claros)
3. Información secundaria en gris
4. Diseño profesional (para usuarios B2B)

---

## 17. INSTRUCCIONES PARA USAR ESTE CONTEXTO

1. **Pasa este documento a una IA** (ChatGPT, Claude, etc.)
2. **Pide que:**
   - Diseñe todas las vistas con Figma o similar
   - O genere el código frontend completo (Vue + Tailwind)
   - Mantenga el paleta Dark Navy + Orange
   - Siga la estructura de carpetas especificada
   - Implemente todos los componentes mencionados
   - Asegure responsividad y accesibilidad

3. **Proporciona las referencias visuales** (capturas de Almacenes Point)

4. **Integra el resultado** en `src/` del proyecto

---

## 18. NOTAS IMPORTANTES

- RLS en Supabase debe estar **ACTIVA** en todas las tablas de datos
- Cada usuario ve solo sus prospectos, búsquedas y guardados
- Google Places Key **NUNCA** se expone al cliente
- Todas las búsquedas pasan por Supabase Edge Functions
- Rate limiting implementado por usuario y por día
- Logs sin datos sensibles de negocios consultados
- El diseño debe ser **minimalista y funcional**, no decorativo

---

**Última actualización:** 2026-04-22  
**Proyecto:** Prospector Web MVP  
**Stack:** Vue 3 + Supabase + Tailwind CSS v4
