# Prospector Web MVP

Herramienta SaaS de prospección de negocios sin presencia web en Quito, Ecuador.

## Stack

- **Frontend**: Vue 3 + TypeScript + Vite + Tailwind CSS v4
- **Estado**: Pinia
- **Router**: Vue Router 4
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions)
- **APIs**: Google Places + SRI Ecuador
- **Hosting**: Vercel (frontend) + Supabase (backend)

## Setup local

### 1. Instalar dependencias
```bash
npm install
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env.local
# Editar .env.local con tus credenciales de Supabase
```

### 3. Deploy de migraciones Supabase
```bash
npx supabase db push
npx supabase functions deploy
```

### 4. Ejecutar en desarrollo
```bash
npm run dev
# Abrirá en http://localhost:5173
```

### 5. Lint antes de commit
```bash
npm run lint
```

## Estructura

```
src/
├── components/       # Vue components reutilizables
│   ├── common/      # Button, Input, Modal, etc.
│   ├── layout/      # Header, Sidebar
│   └── search/      # SearchForm, Results
├── composables/     # Lógica reutilizable (useAuth, useSupabase, etc.)
├── stores/          # Pinia stores (auth, prospect, cost, admin)
├── views/           # Páginas completas
├── router/          # Vue Router config
└── main.ts          # Entry point

supabase/
├── migrations/      # Esquema versionado
└── functions/       # Edge Functions (Google Places, SRI, Score)
```

## Comandos

- `npm run dev` — Desarrollo local (http://localhost:5173)
- `npm run build` — Build producción
- `npm run lint` — ESLint
- `npm run preview` — Preview del build

## Documentación

- **CLAUDE.md**: Contexto de negocio y reglas de código
- **supabase/migrations/*.sql**: Esquema de BD
- **src/views/*.vue**: Flujos de usuario
