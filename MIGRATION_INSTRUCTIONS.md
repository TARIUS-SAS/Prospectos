# Instrucciones para Ejecutar Migraciones en Supabase

**Proyecto**: fpfgjsxlnsofywlazrar  
**URL**: https://fpfgjsxlnsofywlazrar.supabase.co

## Opción 1: Ejecutar vía Supabase SQL Editor (Recomendado - 5 min)

1. **Ir a Supabase Dashboard**
   ```
   https://app.supabase.com/project/fpfgjsxlnsofywlazrar
   ```

2. **Acceder a SQL Editor**
   - Lado izquierdo → "SQL Editor"
   - Click en "+ New Query"

3. **Copiar y ejecutar cada migración en orden**
   
   Ejecutar en este orden:
   ```
   1. supabase/migrations/20260422120000_create_billing_plans.sql
   2. supabase/migrations/20260422120100_create_users_metadata.sql
   3. supabase/migrations/20260422120200_create_prospects.sql
   4. supabase/migrations/20260422120300_create_prospect_versions.sql
   5. supabase/migrations/20260422120400_create_searches.sql
   6. supabase/migrations/20260422120500_create_saved_prospects.sql
   7. supabase/migrations/20260422120600_create_search_parameters.sql
   8. supabase/migrations/20260422120700_create_cost_logs.sql
   9. supabase/migrations/20260422120800_create_prospect_access_log.sql
   10. supabase/migrations/20260422120900_create_admin_settings.sql
   11. supabase/migrations/20260422121000_create_user_subscriptions.sql
   ```

4. **Para cada migración**:
   - Copiar contenido del archivo SQL
   - Pegar en SQL Editor
   - Click "Run" (o Cmd+Enter)
   - Verificar ✅ (sin errores)

---

## Opción 2: Ejecutar vía Supabase CLI (Si tienes acceso token)

```bash
# 1. Login a Supabase
supabase login

# 2. Link proyecto
supabase link --project-ref fpfgjsxlnsofywlazrar

# 3. Push migraciones
supabase db push

# 4. Verificar
supabase db list
```

---

## Opción 3: Ejecutar Script SQL Combined (Avanzado)

Si prefieres ejecutar todo de una vez:

1. **Crear archivo `migrations_combined.sql`** con el contenido de todas las migraciones combinadas
2. **Copiar en SQL Editor** de Supabase
3. **Click "Run"**

**Nota**: No recomendado para producción (mejor traceability con migraciones individuales)

---

## Validación Post-Migraciones

### Paso 1: Verificar tablas creadas

En **Supabase Dashboard → Table Editor**:

- [ ] `billing_plans` — 3 planes (Starter, Professional, Enterprise)
- [ ] `users_metadata` — Vacía (se completa al crear usuarios)
- [ ] `prospects` — Vacía (se completa con búsquedas)
- [ ] `prospect_versions` — Vacía (historial de cambios)
- [ ] `searches` — Vacía (historial de búsquedas)
- [ ] `saved_prospects` — Vacía (prospectos guardados)
- [ ] `search_parameters` — Vacía (búsquedas guardadas)
- [ ] `cost_logs` — Vacía (histórico de costos)
- [ ] `prospect_access_log` — Vacía (auditoría de acceso)
- [ ] `admin_settings` — 3 registros (costos operacionales)
- [ ] `user_subscriptions` — Vacía (suscripciones de usuarios)

### Paso 2: Verificar RLS Policies

En **Supabase Dashboard → Auth → Policies**:

Debe haber 21 policies en total:
- `prospects_select_all` (SELECT all)
- `prospects_update_creador` (UPDATE only creador/admin)
- `users_metadata_select_own_or_admin` (SELECT)
- `users_metadata_update_own_or_admin` (UPDATE)
- ... (y 17 más para otras tablas)

### Paso 3: Insertar datos de prueba

```sql
-- Verificar que billing_plans fue creada con datos
SELECT * FROM billing_plans;
-- Resultado esperado: 3 filas (Starter, Professional, Enterprise)

-- Verificar que admin_settings fue creada
SELECT * FROM admin_settings;
-- Resultado esperado: 3 filas (costo_google_places_per_result, etc.)
```

### Paso 4: Probar RLS

```sql
-- Esto debería retornar datos (SELECT all permitido)
SELECT COUNT(*) FROM prospects;

-- Esto debería fallar (sin auth context)
-- UPDATE prospects SET nombre='Test' WHERE id='xxx';
-- Error esperado: "new row violates row-level security policy"
```

---

## Testing Local (npm run dev)

Una vez las migraciones están aplicadas:

```bash
# 1. Iniciar servidor local
npm run dev

# 2. Abrir http://localhost:5173

# 3. Verificar en F12 Console
# Esperado: 0 errores (solo warnings)

# 4. Network tab
# Verificado que las llamadas a Supabase se hacen a:
# https://fpfgjsxlnsofywlazrar.supabase.co/rest/v1/...
```

---

## Rollback (Si algo falla)

Si necesitas revertir las migraciones:

```sql
-- En SQL Editor de Supabase, ejecutar en orden INVERSO:

DROP TABLE IF EXISTS user_subscriptions;
DROP TABLE IF EXISTS admin_settings;
DROP TABLE IF EXISTS prospect_access_log;
DROP TABLE IF EXISTS cost_logs;
DROP TABLE IF EXISTS search_parameters;
DROP TABLE IF EXISTS saved_prospects;
DROP TABLE IF EXISTS searches;
DROP TABLE IF EXISTS prospect_versions;
DROP TABLE IF EXISTS prospects;
DROP TABLE IF EXISTS users_metadata;
DROP TABLE IF EXISTS billing_plans;
```

**Nota**: Esto borrará todos los datos. No hacer en producción.

---

## Status

- [x] 11 archivos SQL listos
- [x] Credenciales Supabase validadas
- [ ] Migraciones ejecutadas
- [ ] RLS policies verificadas
- [ ] Datos de prueba insertados
- [ ] Local dev validado (npm run dev)

**Próximo paso**: Ejecutar migraciones + validar + ir a Etapa 10
