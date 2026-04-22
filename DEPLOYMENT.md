# Deployment Guide — Prospector Web MVP

## Pre-Staging Checklist

### 1. Code & Git
- [x] Todos los bloqueantes corregidos (24/24)
- [x] ESLint: 0 errores
- [x] Tests unitarios: 13/13 PASS
- [x] Build sin errores
- [x] Commits con mensaje descriptivo
- [x] Rama actualizada con main

### 2. Supabase Configuration

#### Staging Project
```bash
# Crear proyecto staging en Supabase
# Settings → General → Copy Project URL y Anon Key
VITE_SUPABASE_URL="https://staging-xxxx.supabase.co"
VITE_SUPABASE_ANON_KEY="eyJhbGc..."
```

#### Environment Variables
- [x] ALLOWED_ORIGIN=https://prospector-staging.vercel.app
- [x] GOOGLE_PLACES_API_KEY (en Supabase secrets, no en .env)
- [x] Verificar que Service Role Key NO está expuesta

#### Database Migrations
```bash
# Ejecutar todas las migraciones en staging
supabase db push --project-ref staging_project_id
# Verificar 11 tablas creadas:
# billing_plans, users_metadata, prospects, prospect_versions,
# searches, saved_prospects, search_parameters, cost_logs,
# prospect_access_log, admin_settings, user_subscriptions
```

#### RLS Policies
- [x] Verificar 21 policies creadas
- [x] SELECT all en prospects, admin_settings
- [x] UPDATE/INSERT/DELETE filtered por usuario_id
- [x] admin_settings READ-ONLY (no UPDATE)

#### Default Data
```sql
-- Insertar planes de billing en staging
INSERT INTO billing_plans (nombre, costo_búsqueda_venta, costo_empresa_venta, costo_guardado_venta)
VALUES
  ('Starter', 0.50, 0.05, 0.10),
  ('Professional', 0.40, 0.03, 0.08),
  ('Enterprise', 0.30, 0.02, 0.05);

-- Insertar admin_settings
INSERT INTO admin_settings (clave, valor)
VALUES
  ('costo_google_places_per_result', '0.0034'),
  ('costo_sri_per_query', '0.001'),
  ('costo_empresa_real', '0.0020');
```

### 3. Vercel Configuration

#### Environment Variables en Vercel
Acceder a: Settings → Environment Variables

**Variables a configurar**:
```
VITE_SUPABASE_URL = https://staging-xxxx.supabase.co
VITE_SUPABASE_ANON_KEY = eyJhbGc...
```

**No incluir**:
- GOOGLE_PLACES_API_KEY (va en Supabase secrets)
- Credenciales de usuarios

#### Build Settings
- Framework: Vite
- Build Command: `npm run build`
- Output Directory: `dist`
- Development Command: `npm run dev`

### 4. Security Review Pre-Deploy

- [x] HTTPS habilitado en Vercel (automático)
- [x] Headers de seguridad en vercel.json (HSTS, CSP, etc.)
- [x] RLS policies verificadas en Supabase
- [x] API keys no hardcodeadas
- [x] .env no tracked en git
- [x] Service Role Key en Supabase secrets, no en Vercel env vars
- [x] ALLOWED_ORIGIN correcto para staging/producción

### 5. Testing Pre-Deploy

```bash
# Local testing
npm run build      # Verifica que la build es exitosa
npm run preview    # Simula servidor de producción en local
npm run test       # Ejecutar tests unitarios
npm run lint       # Verificar código

# Humo test manual
# 1. Navegar a http://localhost:4173 (preview)
# 2. Intentar login (fallará sin Supabase real)
# 3. Verificar que la estructura renderiza sin errores
# 4. Chequear console (F12) por errores de JS
```

### 6. Staging Deploy Steps

#### Opción A: Deploy manual vía Vercel CLI
```bash
npm install -g vercel
vercel --prod --env VITE_SUPABASE_URL=https://staging-xxx.supabase.co
```

#### Opción B: Deploy vía Git (Recomendado)
```bash
# 1. Crear rama staging
git checkout -b staging

# 2. Push a remoto
git push origin staging

# 3. Conectar rama a Vercel
# Settings → Git Integration → Production Branch = main, Preview = staging

# 4. Deploy automático en cada push a staging
```

### 7. Smoke Test en Staging

**URL**: https://prospector-staging.vercel.app (o similar)

#### Test 1: Estructura renderiza
```bash
curl -I https://prospector-staging.vercel.app
# Verificar: 200 OK
# Headers: Strict-Transport-Security, Content-Security-Policy presente
```

#### Test 2: Login renderiza sin errores
```
1. Navegar a /login
2. F12 → Console: ¿Sin errores de JS?
3. Formulario visible: Email input, Password input, Submit button
```

#### Test 3: Router guards funcionan
```
1. Navegar a /dashboard (sin auth)
2. Debería redirigir a /login
3. Navegar a /admin (sin auth)
4. Debería redirigir a /login
```

#### Test 4: Assets se cargan
```
1. F12 → Network
2. Verificar que CSS, JS, imágenes cargan exitosamente (200 OK)
3. Sin 404s
4. Gzip compression activa (Content-Encoding: gzip)
```

#### Test 5: CSP no bloquea recursos
```
1. F12 → Console
2. ¿Hay warnings de CSP?
3. Si las hay, actualizar vercel.json y redeploy
```

---

## Checklist de Staging

| Ítem | Status | Notas |
|---|---|---|
| Build sin errores | ✅ | Verificado localmente |
| Migraciones en staging | ⏳ | Ejecutar con `supabase db push` |
| RLS policies activas | ⏳ | Verificar en Supabase dashboard |
| Vercel env vars | ⏳ | Configurar VITE_SUPABASE_URL, KEY |
| Headers de seguridad | ✅ | vercel.json ya tiene |
| Smoke test en staging | ⏳ | Post-deploy |

---

## Rollback Plan

Si algo falla en staging:

```bash
# Opción 1: Revertir a último commit
git revert <commit-hash>
git push origin staging

# Opción 2: Desactivar preview en Vercel
# Settings → Production → desactivar rama staging

# Opción 3: Borrar deployment fallido
vercel rm prospector-staging --yes
```

---

## Próximos Pasos (Post-Staging)

1. **Etapa 10**: Production Deployment
   - [ ] Crear proyecto production en Supabase
   - [ ] Configurar Vercel custom domain
   - [ ] Realizar backup de datos staging
   - [ ] Plan de rollback escrito

2. **Etapa 11**: Monitoring
   - [ ] Dashboards en Vercel, Supabase
   - [ ] Alertas configuradas
   - [ ] Logs centralizados

3. **Etapa 12**: Feedback & Metrics
   - [ ] Métricas iniciales vs post-lanzamiento
   - [ ] User acceptance testing
   - [ ] Mejoras para v1.1

---

## Contactos & Escalamiento

- **Mateo (Founder)**: hmateojurado@gmail.com
- **Supabase Status**: https://status.supabase.com
- **Vercel Status**: https://www.vercel.com/status

---

## Comandos Rápidos

```bash
# Build
npm run build && npm run preview

# Tests
npm test -- run

# Lint
npm run lint

# Local dev
npm run dev

# Supabase (si está instalado)
supabase start
supabase db push
supabase functions deploy
```
