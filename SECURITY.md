# Seguridad — Prospector Web MVP

## Headers HTTP (Configurados en vercel.json)

✅ **Strict-Transport-Security** (HSTS)
- `max-age=31536000; includeSubDomains; preload`
- Fuerza HTTPS por 1 año, preload en navegadores modernos

✅ **X-Content-Type-Options**
- `nosniff` — previene MIME sniffing attacks

✅ **X-Frame-Options**
- `DENY` — previene clickjacking

✅ **X-XSS-Protection**
- `1; mode=block` — legacy XSS protection para navegadores antiguos

✅ **Referrer-Policy**
- `strict-origin-when-cross-origin` — controla qué referrer se envía

✅ **Content-Security-Policy** (CSP)
- `default-src 'self'` — solo recursos del mismo origen por defecto
- `script-src 'self' 'unsafe-inline' 'unsafe-eval'` — Vue 3 requiere inline/eval para reactivity
- `style-src 'self' 'unsafe-inline'` — Tailwind CSS genera inline styles
- `img-src 'self' data: https:` — imágenes locales, data URLs, y HTTPS externas
- `font-src 'self' data:` — fuentes locales y data URLs
- `connect-src 'self' https://api.supabase.co https://*.supabase.co` — API calls a Supabase

---

## Autenticación y Autorización

✅ **Supabase JWT + Role-Based Access**
- Tokens con expiración automática (3600s)
- Roles en `auth.users.raw_app_meta_data.role` (admin | user)
- Router guards verifican `requiresAuth` y `requiresAdmin` antes de cada ruta
- Logout invalida sesión en Supabase

✅ **Row-Level Security (RLS)**
- Habilitada en 8 tablas:
  - `prospects`: SELECT todos, UPDATE solo creador/admin
  - `searches`: SELECT/INSERT/UPDATE solo propietario
  - `saved_prospects`: SELECT/INSERT/UPDATE/DELETE solo propietario
  - `user_subscriptions`: SELECT propietario o admin
  - `users_metadata`: SELECT/UPDATE propietario o admin
  - `cost_logs`: SELECT solo propietario
  - `prospect_access_log`: SELECT solo propietario
  - `admin_settings`: SELECT admin only (READ-ONLY)

✅ **Service Role Key**
- Almacenada en Supabase secrets (no exponerse al cliente)
- Usada solo en Edge Functions (backend)

✅ **Anon Key**
- Almacenada en `.env` (acceso limitado por RLS)
- Usada en frontend

---

## Validación de Inputs (Backend)

✅ **SQL Injection Prevention**
- Supabase SDK usa parámetros preparados, no concatenación
- Ejemplo: `.eq('usuario_id', user.id)` — no crea string con user input

✅ **Input Validation**
- `query` y `zona` requeridas en búsquedas
- `cantidad_resultados` validado 1-50
- Email validado por Supabase en autenticación
- Parámetros opcionales (tipo_negocio, empleados_range, etc.) sin inyección

✅ **No XSS**
- Vue 3 escapa outputs por defecto (no usa `innerHTML`)
- Template strings interpoladas `{{ }}` son escapadas automáticamente
- Supabase outputs también escapados (datos de BD)

---

## Manejo de Datos Sensibles

✅ **Contraseñas**
- Bcrypt + Supabase (nunca MD5 o SHA1 solo)
- Nunca almacenadas en cliente

✅ **API Keys**
- `.env.example` documentado, nunca commiteado `.env`
- `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` en `.env`
- `GOOGLE_PLACES_API_KEY` en Supabase secrets (Edge Functions)
- `ALLOWED_ORIGIN` en Supabase env (CORS)

✅ **Logs**
- No incluyen contraseñas, tokens, o datos personales
- `console.error()` solo de errores técnicos

---

## Rate Limiting

✅ **Por Usuario (implementado)**
- Validado en `search-google-places` Edge Function
- Límite configurable por usuario en `users_metadata.búsquedas_max_por_día` (default 20)
- Retorna 429 si excedido

⚠️ **Global (no implementado en MVP)**
- Recomendado para producción: limitar por IP/dominio
- **Opciones**:
  1. Cloudflare (gratis): WAF rules para rate limit por IP
  2. AWS WAF: más granular, pagado
  3. Vercel Pro: middleware nativo (pagado)
  4. Custom Edge Middleware (Deno): implementar en Supabase Edge Function

---

## OWASP Top 10 — Checklist

| Riesgo | Mitigación | Estado |
|---|---|---|
| **SQL Injection** | Parámetros preparados (Supabase SDK) | ✅ Mitigado |
| **Broken Authentication** | JWT + RLS + logout explícito | ✅ Mitigado |
| **Sensitive Data Exposure** | API keys en env/secrets, HTTPS via Vercel | ✅ Mitigado |
| **XML External Entities (XXE)** | No procesa XML | ✅ N/A |
| **Broken Access Control** | RLS + router guards + admin checks | ✅ Mitigado |
| **Security Misconfiguration** | CSP, HSTS, headers configurados | ✅ Mitigado |
| **Cross-Site Scripting (XSS)** | Vue escapa outputs, CSP activa | ✅ Mitigado |
| **Insecure Deserialization** | JSON.parse solo en request body (type-safe) | ✅ Mitigado |
| **Using Components with Known Vulns** | npm audit: 0 vulnerabilidades | ✅ Verificado |
| **Insufficient Logging & Monitoring** | prospect_access_log, searches audit trail | ✅ Implementado |

---

## Dependencias

✅ **npm audit: 0 vulnerabilidades**

Versiones fijadas en `package.json`:
- @supabase/supabase-js 2.104.0 (mantenida activamente)
- vue 3.5.32 (versión estable)
- vite 8.0.9 (versión estable)
- tailwindcss 4.2.4 (versión estable)

✅ **package-lock.json commiteado** (reproducibilidad)

---

## CORS

✅ **ALLOWED_ORIGIN Requerido**
- `Deno.env.get("ALLOWED_ORIGIN")` sin fallback (falla explícita si no configurado)
- Previene CORS bypass silencioso

✅ **Methods Restringidos**
- POST, OPTIONS solamente (no GET, PUT, DELETE)

✅ **Headers Específicos**
- authorization, content-type solamente

---

## Checklist Pre-Producción

- [ ] npm audit ejecutado regularmente (agregar a CI/CD)
- [ ] ALLOWED_ORIGIN configurado en Supabase (no localhost en prod)
- [ ] VITE_SUPABASE_URL verificado (proyecto correcto)
- [ ] VITE_SUPABASE_ANON_KEY verificado (credenciales correctas)
- [ ] Vercel headers verificados en producción (vercel.json aplicado)
- [ ] HTTPS habilitado (Vercel por defecto)
- [ ] RLS policies verificadas en Supabase dashboard
- [ ] Admin role asignado solo a Mateo
- [ ] Rate limit diario revisado (20 búsquedas por defecto)
- [ ] Backups de Supabase activados

---

## Monitoreo Post-Deploymentt

- Verificar logs de Vercel para errores 4xx/5xx anormales
- Monitorear Supabase para queries anormales (posible SQL injection)
- Revisar `prospect_access_log` para patrones de scraping
- Alertar si usuario excede límite diario múltiples veces (posible ataque)

---

## Contacto

Reportar vulnerabilidades a: hmateojurado@gmail.com (Mateo, fundador TARIUS)
