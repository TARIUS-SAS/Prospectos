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

## Paleta visual
Paleta adaptada de Tarius con ajustes para mejor legibilidad:
- Primary (acciones): cobre #b87333
- Background principal: crema #e8d8cb
- Text primary: navy #1a2735
- Accent (score alto, éxito): verde #22c55e
- Danger (errores): rojo #ef4444
- Surface (cards): blanco #ffffff
