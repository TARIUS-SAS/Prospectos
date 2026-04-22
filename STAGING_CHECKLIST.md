# Staging Pre-Deploy Checklist

**Fecha**: 2026-04-22  
**Versión**: 0.1.0 MVP  
**Status**: 🟡 PRONTO PARA STAGING

---

## ✅ Completado en Desarrollo

- [x] Build sin errores (320ms)
- [x] Lint: 0 errores, 31 warnings (any types OK)
- [x] Tests unitarios: 13/13 PASS
- [x] E2E smoke tests: Definidos
- [x] Security audit: OWASP Top 10 pasado
- [x] All 24 bloqueantes corregidos
- [x] 11 migrations con RLS
- [x] 3 Edge Functions
- [x] API documentation (.env.example)
- [x] vercel.json configurado
- [x] SECURITY.md escrito
- [x] DEPLOYMENT.md escrito

---

## ⏳ A Hacer Antes de Staging

### Supabase Setup (10 min)

- [ ] Crear proyecto "prospector-staging" en Supabase
- [ ] Copiar Project URL y Anon Key
- [ ] Habilitar GitHub integration para auto-deploy de migrations
- [ ] Ejecutar todas las 11 migrations:
  ```bash
  supabase db push --project-ref staging_project_id
  ```
- [ ] Verificar 11 tablas creadas en Supabase dashboard
- [ ] Insertar datos de prueba (billing_plans, admin_settings)
- [ ] Verificar 21 RLS policies activas
- [ ] Generar test JWT para pruebas manuales

### Vercel Setup (5 min)

- [ ] Conectar repositorio a Vercel (si no está)
- [ ] Agregar environment variables:
  - `VITE_SUPABASE_URL` = https://staging-xxx.supabase.co
  - `VITE_SUPABASE_ANON_KEY` = (copiar de Supabase)
- [ ] Configurar Preview branch (staging)
- [ ] Configurar Production branch (main)
- [ ] Verificar Build Command: `npm run build`
- [ ] Verificar Install Command: `npm install`

### Pre-Deploy Validation (5 min)

- [ ] `npm run build` exitoso
- [ ] `npm run lint` sin errores
- [ ] `npm test -- run` todos los tests pass
- [ ] `git log -1` muestra último commit con descripción clara
- [ ] `.env` no tracked en git (verificar `.gitignore`)
- [ ] `.env.example` completamente documentado

### Push a Staging (5 min)

```bash
# 1. Crear rama staging
git checkout -b staging

# 2. Agregar cambios (si es primera vez)
git add DEPLOYMENT.md STAGING_CHECKLIST.md QA_TEST_PLAN.md

# 3. Commit
git commit -m "docs: Deployment and staging documentation"

# 4. Push
git push origin staging

# 5. Vercel debería auto-deploy a preview/staging
# Monitorear: https://vercel.com/dashboard
```

---

## 🧪 Post-Deploy Validation en Staging

**Esperado**: ~5-10 min después del push

- [ ] Vercel deploy completado (mostrar ✅)
- [ ] Deploy preview URL generada (ej: prospector-staging.vercel.app)
- [ ] Logs sin errores (Vercel Functions)

### Health Checks

```bash
# Test 1: HTTP status
curl -I https://prospector-staging.vercel.app
# Esperado: 200 OK

# Test 2: Headers de seguridad presentes
curl -I https://prospector-staging.vercel.app | grep "Strict-Transport-Security"
# Esperado: Strict-Transport-Security presente

# Test 3: Assets cargan
curl https://prospector-staging.vercel.app | head -20
# Esperado: HTML con <div id="app">
```

### Manual Testing en Browser

1. **Navegar a staging URL**
   ```
   https://prospector-staging.vercel.app
   ```

2. **Verificar estructura renderiza**
   - [ ] Logo "PROSPECTOR" visible
   - [ ] "Encuentra clientes sin web" visible
   - [ ] Email y Password inputs visibles
   - [ ] Botón "ENTRAR" visible

3. **Abrir DevTools (F12)**
   - [ ] Console: ¿Sin errores de JS? (Esperado: 0 errores críticos)
   - [ ] Network: ¿Todos los assets cargan? (Esperado: todos 200 OK)
   - [ ] Network → Throttle a "Slow 3G": ¿Sigue funcional? (UX)

4. **Testar form validation**
   - [ ] Hacer clic "ENTRAR" sin email → Mostrar "Email requerido"
   - [ ] Ingresar email, sin password → Mostrar "Contraseña requerida"
   - [ ] Email inválido (ej: "notanemail") → Supabase rechaza

5. **Testar router guards**
   - [ ] Navegar a /dashboard → Redirige a /login
   - [ ] Navegar a /admin → Redirige a /login
   - [ ] Navegar a /search → Redirige a /login

6. **Verificar CSP headers**
   - [ ] F12 → Application → Cookies: ¿Supabase cookies presentes?
   - [ ] F12 → Console: ¿Sin "Refused to X due to Content Security Policy"?

---

## 🚨 Si Algo Falla

| Problema | Solución | Contacto |
|---|---|---|
| Vercel deploy falló | Ver logs en Vercel → Environment variables correctas? | DevOps |
| Supabase no responde | Verificar status.supabase.com | SRE |
| CSP bloquea recursos | Actualizar vercel.json, redeploy | Security |
| RLS policies incorrectas | Verificar Supabase RLS dashboard | DBA |

---

## ✅ Approval Sign-Off

- **Tech Lead**: _________________ (Firma)
- **QA**: _________________ (Firma)
- **Date**: _________________

Once signed, proceed to Etapa 10 (Production).

---

## Status Histórico

| Date | Versión | Status | Notes |
|---|---|---|---|
| 2026-04-22 | 0.1.0-beta | 🟡 Ready for Staging | Todos los bloqueantes corregidos |
| TBD | 0.1.0 | 🟢 Production | Post Etapa 10 |
