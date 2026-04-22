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
- `npm run test` — Tests unitarios (Vitest)
- `npm run preview` — Preview del build

## Testing

```bash
# Tests unitarios (lógica de scoring, costos, seguridad)
npm test -- run

# E2E smoke tests (requiere servidor en http://localhost:4173)
npx playwright test

# Ver cobertura de tests
npm test -- --coverage
```

Ver **QA_TEST_PLAN.md** para detalles completos.

## Documentación

- **CLAUDE.md**: Contexto de negocio y reglas de código
- **SECURITY.md**: Auditoría de seguridad, OWASP checklist
- **DEPLOYMENT.md**: Guía de deployment (Staging & Production)
- **STAGING_CHECKLIST.md**: Checklist antes/después de staging
- **QA_TEST_PLAN.md**: Plan de testing y validación manual
- **supabase/migrations/*.sql**: Esquema versionado de BD
- **src/views/*.vue**: Vistas y flujos de usuario

## Status

✅ **MVP Completado** (Etapa 8)
- Todas las rutas funcionales implementadas
- Tests unitarios: 13/13 PASS
- Security audit: OWASP Top 10 completado
- Build: Sin errores, 10.6 KB gzip

🟡 **Pronto para Staging** (Etapa 9)
- Seguir **DEPLOYMENT.md** para setup de Supabase staging
- Seguir **STAGING_CHECKLIST.md** para validación post-deploy

## Próximas Iteraciones

- [ ] Google Places API real (actualmente mock)
- [ ] SRI API real (actualmente mock)
- [ ] E2E tests con usuario real
- [ ] Performance profiling
- [ ] Analytics & monitoring
