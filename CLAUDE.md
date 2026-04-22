# Proyecto: Prospector Web

## Contexto de negocio
Herramienta de prospección de negocios sin presencia web para Ecuador (Quito principalmente). Se usa para identificar comercios pequeños y medianos que son candidatos a servicios de diseño web, y generar una lista priorizada por score de prospecto.

## Usuarios
- Admin principal (Mateo, fundador de Tarius SAS)
- Colaborador (amigo, acceso a sus propias búsquedas y prospectos)
- Estructura preparada para crecer a más usuarios sin rehacer el esquema

## Stack
- Frontend: Vue 3 + Vite + Composition API con `<script setup>`
- Router: Vue Router 4
- Estado: Pinia
- Estilos: Tailwind CSS v4
- Backend/DB: Supabase (PostgreSQL + Auth + Edge Functions)
- APIs externas: Google Places API (New), SRI Ecuador (consulta pública de RUC)
- Hosting: Vercel (plan free)

## Variables de entorno
Variables en `.env` (NUNCA commitear):
- `VITE_SUPABASE_URL` — Project URL de Supabase
- `VITE_SUPABASE_ANON_KEY` — anon key pública de Supabase
- La Google Places Key NO va en el frontend: se configura como secret en Supabase Edge Functions

## Reglas de código
- Componentes en PascalCase: `BusinessCard.vue`, `ProspectList.vue`
- Composables con prefijo `use`: `useBusinesses.js`, `useScoring.js`
- Mensajes de commit en español con conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Nunca commitear `.env` ni credenciales reales
- Siempre correr `npm run lint` antes de cerrar una tarea
- Archivos de más de 300 líneas se dividen en módulos más pequeños

## Estructura de carpetas
- `/src/components` — componentes reutilizables
- `/src/views` — páginas completas (BusinessListView, BusinessDetailView, LoginView)
- `/src/composables` — lógica reutilizable (useSupabase, useGooglePlaces, useSRI)
- `/src/stores` — estado global con Pinia
- `/src/services` — clientes de APIs externas
- `/src/utils` — funciones puras (scoring, formateo)
- `/supabase/migrations` — esquema SQL versionado
- `/supabase/functions` — Edge Functions (llamadas a Google Places)

## Reglas de negocio del scoring
Puntaje de prospecto (0-24):
- Sin website: +10
- Website solo Facebook/Instagram: +7
- Website sin HTTPS: +5
- Activo en SRI: +3
- Tiene teléfono: +2
- Zona comercial (centro Quito, Cumbayá, La Carolina, etc.): +2

Prospectos con score ≥ 15 se marcan como "calientes" y se muestran primero.

## Reglas de seguridad no negociables
- RLS (Row Level Security) activa en TODAS las tablas de Supabase
- Cada usuario ve solo sus propios prospectos y búsquedas
- Google Places Key NUNCA expuesta al cliente: todas las llamadas pasan por Edge Functions
- Rate limit inicial: máximo 20 búsquedas por usuario por día
- Logs sin datos personales sensibles de negocios consultados
- Tablas con `created_by` (uuid referenciando auth.users) en todas las tablas de datos

## Volumen inicial
- 20 negocios por búsqueda
- ~5 búsquedas por día por usuario al inicio
- Costo proyectado: $5-15 USD/mes en Google Places API

## Comandos
- `npm run dev` — desarrollo local en `localhost:5173`
- `npm run build` — build de producción
- `npm run lint` — ESLint
- `npm run test` — tests unitarios (cuando se agreguen)

## Identidad Visual

### Dirección estética
**Neogeo Contemporáneo**: Geometrías vivas, asimetría inteligente, movimiento suave. UI moderna que celebra la prospección. Audacia controlada, densidad respirada, premium pero accesible.

### Tipografía

**Display (encabezados principales, títulos destacados)**
- Fuente: **Clash Grotesk** (gratuita en Fontshare, variante Bold 700)
- Pesos: 700 (Bold)
- Tamaño base: 32px (h1), 28px (h2), 24px (h3)
- Uso: Headers de página, títulos de sección, números de stats principales
- Características: Geométrica, contemporánea, distinctive, weight visual

**Body (párrafos, etiquetas, descripciones)**
- Fuente: **Geist** (gratuita de Vercel, variable font)
- Pesos: 400 (Regular), 500 (Medium), 600 (SemiBold)
- Tamaño base: 16px (default), 14px (small), 12px (micro)
- Line-height: 1.6 (body), 1.5 (labels)
- Uso: Contenido, descripciones, metadatos, validaciones
- Características: Warmth, accesible, legible en pequeño, moderna

**Escala tipográfica (valores en px)**
```
h1: 32px / 700 / 1.2
h2: 28px / 700 / 1.3
h3: 24px / 700 / 1.4
h4: 20px / 600 / 1.4
body: 16px / 400 / 1.6
label: 14px / 500 / 1.5
micro: 12px / 400 / 1.4
```

### Paleta de color

**Colores primarios (no cambian)**
```css
--color-copper: #b87333;      /* Primary: acciones, números stats, gradientes */
--color-cream: #e8d8cb;        /* Background secondary, espacios respirados */
--color-navy: #1a2735;         /* Text, contraste, bordes detalles */
```

**Color secundario derivado**
```css
--color-coral: #ff6b35;        /* Derivado cobre (gradiente cobre→coral en stats) */
```

**Escala de grises (basada en navy)**
```css
--gray-900: #0f1419;           /* Darkest, equivalente navy puro */
--gray-800: #1a2735;           /* Navy base (primary text) */
--gray-700: #2d3e52;
--gray-600: #4a5f78;
--gray-500: #6b7f99;
--gray-400: #8fa1b8;
--gray-300: #b3c1d4;
--gray-200: #d6dce6;
--gray-100: #eef0f6;
--gray-50: #f7f8fc;            /* Almost white with cool tint */
```

**Semánticos (operacionales)**
```css
--success: #22c55e;            /* Verde éxito, checkmarks, estados positivos */
--error: #ef4444;              /* Rojo errores, validaciones fallidas */
--warning: #f59e0b;            /* Ámbar alertas, datos incompletos */
--info: #3b82f6;               /* Azul información, tooltips */
```

**Paleta en pantalla**
- Cromático total: 25-30% (audaz pero balanceado)
- Blanco puro mínimo: usar gray-50 o crema
- Fondos principales: gray-50 o white
- Fondos secundarios: crema con 10% opacity o gray-100
- Acentos: cobre en bloques asimétricos, coral en gradientes de datos positivos

### Variables CSS en `tailwind.config.js`

Configurar en `extend.colors`:
```javascript
colors: {
  copper: '#b87333',
  cream: '#e8d8cb',
  navy: '#1a2735',
  coral: '#ff6b35',
  gray: { /* escala completa */ },
  success: '#22c55e',
  error: '#ef4444',
  warning: '#f59e0b',
  info: '#3b82f6'
}
```

Configurar en `extend.backgroundImage` (gradientes signature):
```javascript
gradients: {
  'copper-to-coral': 'linear-gradient(135deg, #b87333, #ff6b35)',
  'stat-glow': 'linear-gradient(180deg, rgba(184, 115, 51, 0.1), transparent)',
}
```

### Espaciado y densidad

**Principio**: Generoso pero no vacío. Permite respiración visual sin perder funcionalidad.

**Padding base (en unidades Tailwind, 1 unit = 4px)**
- Cards principales: `p-6` (24px)
- Secciones: `p-4` (16px)
- Elementos pequeños: `p-3` (12px)
- Labels/texto pequeño: `px-2 py-1` (8px x 4px)

**Gaps y márgenes**
- Entre cards: `gap-6` (24px)
- Entre secciones: `my-8` (32px)
- Columnas/filas: `gap-4` (16px)

**Densidad aplicada por tipo de vista**
- Dashboard (tabla de prospectos): gap-4, respirado pero compacto
- Card detalle: p-6, muy respirado
- Modal/formulario: p-5, balance
- Lista simple: gap-2, compacta

### Iconografía

**Librería**: **Lucide Vue** (gratuita, consistente, moderna)

**Razón de elección**:
- Gratis y open-source
- 400+ iconos, cobertura completa para datos/negocio
- Rounded style (friendly pero profesional, fit con neogeo)
- Tamaño consistente, scalable sin pérdida
- Buen mantenimiento comunitario

**Tamaños estándar**
- Heading context: `size-6` (24px)
- Button/label context: `size-5` (20px)
- Micro/badge context: `size-4` (16px)
- Decorativos grandes: `size-8` (32px)

**Colores aplicados**
- Acciones primarias: `text-copper`
- Acciones secundarias: `text-gray-600`
- Estados positivos: `text-success` (verde)
- Estados negativos: `text-error` (rojo)
- Decorativos: gradientes cobre→coral

### Animaciones y micro-interacciones

**Duración base (global)**
- Micro-interacciones rápidas: `200ms` (botón hover)
- Transiciones normales: `300-400ms` (page fade, card slide)
- Transiciones lentas: `500-600ms` (loading indicadores suaves)

**Easing (función)**
- Movimientos suaves: `ease-out` (default Tailwind)
- Spring (bouncy): custom `cubic-bezier(0.34, 1.56, 0.64, 1)` (spring effect)
- Fade: `ease-in-out` solo para opacity

**Micro-interacciones específicas por elemento**

*Botones y links*
- Hover: `scale-105 + shadow-lg` (300ms ease-out)
- Active: `scale-95` (100ms)
- Disabled: `opacity-50 cursor-not-allowed`

*Cards principales (asimetría)*
- Default: `shadow-md`
- Hover: `shadow-xl + translate-y-[-4px]` (300ms ease-out)
- Focus: border cobre 2px

*Stats con números en gradiente*
- On mount: fade-in (400ms) + scale-up 0.9→1.0
- Número actualizado: pulse/glow suave (800ms)

*Loading indicators*
- Animated gradient spin: `cobre → coral → cobre` (2s infinite linear)
- Progress bar: width animado (300ms ease-in-out)

*Separadores ondulados*
- SVG path animada (opacity pulse 0.4→1.0, 1.5s ease-in-out infinite)

*Check animado en búsqueda exitosa*
- Checkmark: scale 0→1 + rotate -90°→0° (400ms cubic-bezier spring)
- Color: gray-600 → success (verde)
- Seguido de: contador de prospectos animado (números actualizan con tween)

**Transiciones de página**
- Enter: fade-in (200ms) + slide-up (20px → 0px)
- Exit: fade-out (150ms)

### Detalle Signature (elementos diferenciadores)

1. **Cards principales con shadow dinámico**
   - Shadow normal: `shadow-md`
   - Hover: `shadow-2xl` con offset (translate-y -4px)
   - Efecto: da sensación de "elevación" interactiva

2. **Números stats en gradiente cobre→coral**
   - Color del texto: `bg-gradient-to-r from-copper to-coral bg-clip-text text-transparent`
   - Tipografía: display (Clash Bold)
   - Tamaño: 4xl+
   - Efecto: datos positivos brillan, atrae atención

3. **Separadores línea ondulada sutil**
   - SVG con `<path>` animado en wave shape
   - Stroke: cobre, opacity 20%
   - Animation: pulse suave cada 1.5s
   - Uso: entre secciones principales, divisiones de lógica

4. **Asimetría inteligente en elementos grandes**
   - Cards principales: esquina asimétrica (top-left sharp, otros rounded)
   - O: offset dinámico en border-radius aplicado en Tailwind con plugins custom
   - Efectivo en: card destacada de prospecto, header secciones
   - Nunca en: botones (todos rounded-lg consistentes), inputs, labels

5. **Gradient backgrounds sutiles en cards**
   - Background: `from-copper/5 to-transparent` (gradiente muy suave)
   - O: base `gray-50` sin gradiente, gradiente solo en hover
   - Efecto: profundidad sin ruido

### DO / DON'T

**DO**
- ✓ Usar Clash Grotesk para headers importantes, Geist para body
- ✓ Aplicar gradiente cobre→coral en números stats positivos
- ✓ Mantener gaps generosos (24px+ entre secciones)
- ✓ Usar Lucide icons en color, no monocromo
- ✓ Animaciones suaves (300-400ms ease-out) en interacciones
- ✓ RLS y seguridad en datos sensibles (no visual)
- ✓ Shadows dinámicas en hover (elevation effect)
- ✓ Separadores ondulados para breaks de sección
- ✓ Asimetría solo en elementos decorativos/grandes, no UI funcional
- ✓ Check animado en estados exitosos, no confetti

**DON'T**
- ✗ Usar Inter, Roboto, Arial, Helvetica, Open Sans, Space Grotesk
- ✗ Monocromo en iconografía (siempre color contextual)
- ✗ Animaciones bouncy/spring en textos largos (solo números/CTAs)
- ✗ Asimetría en botones o inputs (solo rounded-lg consistente)
- ✗ Colores sem se refieren a la paleta primaria sin propósito semántico
- ✗ Padding apretado (< 12px) en componentes principales
- ✗ Transiciones mayores a 600ms (se siente lento)
- ✗ Fondos sin ningún contraste con navy text
- ✗ Esquinas sharp en cards (siempre rounded)
- ✗ Cambios de estado sin animación (todo debe transicionar suave)

### Fuentes: URLs de importación

**Clash Grotesk** (vía Fontshare CDN - gratis con account)
```css
@import url('https://api.fontshare.com/v2/css?f[]=clash-grotesk@700');
```

**Geist** (vía Vercel CDN - gratis)
```css
@import url('https://fonts.vercel.app/geist');
```

Ambas en `src/styles/globals.css` o equivalente.

### Principio rector
Prospector es una herramienta moderna para descubrir oportunidades. Cada detalle visual (tipografía, color, movimiento) comunica: "esto es contemporáneo, confiable, y hecho para usuarios serios que valoran lo moderno".
