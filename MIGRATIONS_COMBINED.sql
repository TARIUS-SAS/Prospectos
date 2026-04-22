-- ============================================================================
-- PROSPECTOR WEB - COMBINED MIGRATIONS
-- ============================================================================
-- Execute all 11 migrations in Supabase SQL Editor
-- Copy-paste entire content into https://app.supabase.com/project/fpfgjsxlnsofywlazrar
-- Click "Run" to execute
-- ============================================================================

-- Migration 1: Create billing_plans table
-- Date: 2026-04-22
-- Description: Plans for user subscriptions (Starter, Professional, Enterprise)

BEGIN;

CREATE TABLE IF NOT EXISTS billing_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  búsquedas_max_mes INTEGER,
  costo_búsqueda_venta DECIMAL(10,4) NOT NULL,
  costo_empresa_venta DECIMAL(10,4) NOT NULL,
  costo_guardado_venta DECIMAL(10,4) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Insert default plans
INSERT INTO billing_plans (nombre, descripcion, búsquedas_max_mes, costo_búsqueda_venta, costo_empresa_venta, costo_guardado_venta) VALUES
  ('Starter', '20 búsquedas por mes, ideal para prospectos iniciales', 20, 0.50, 0.05, 0.10),
  ('Professional', '100 búsquedas por mes, para equipos activos', 100, 0.30, 0.03, 0.07),
  ('Enterprise', 'Ilimitado, máxima prospección', NULL, 0.20, 0.02, 0.05);

CREATE INDEX idx_billing_plans_activo ON billing_plans(activo);

COMMIT;

-- ============================================================================
-- Migration 2: Create users_metadata table
-- Date: 2026-04-22
-- Description: User metadata linked to auth.users (plan, limits, settings)

BEGIN;

CREATE TABLE IF NOT EXISTS users_metadata (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES billing_plans(id),
  búsquedas_max_por_día INTEGER NOT NULL DEFAULT 20,
  resultados_por_defecto INTEGER NOT NULL DEFAULT 20,
  fecha_alta TIMESTAMPTZ NOT NULL DEFAULT now(),
  estado VARCHAR(50) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
  notas_internas TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: cada usuario ve su propio metadata, admin ve todos
ALTER TABLE users_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_metadata_own_or_admin" ON users_metadata
  FOR SELECT
  USING (
    auth.uid() = id OR
    (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "users_metadata_update_own" ON users_metadata
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "users_metadata_update_admin" ON users_metadata
  FOR UPDATE
  USING ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin');

CREATE INDEX idx_users_metadata_plan_id ON users_metadata(plan_id);
CREATE INDEX idx_users_metadata_estado ON users_metadata(estado);

COMMIT;

-- ============================================================================
-- Migration 3: Create prospects table (GLOBAL, shared across users)
-- Date: 2026-04-22
-- Description: Central repository of all prospects found (prevents duplication)

BEGIN;

CREATE TABLE IF NOT EXISTS prospects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  dirección VARCHAR(500),
  teléfono VARCHAR(20),
  website VARCHAR(500),
  https BOOLEAN,
  facebook_instagram VARCHAR(500),
  google_rating DECIMAL(3,1),
  google_reviews_count INTEGER,
  tipo_negocio VARCHAR(100),
  empleados_estimados VARCHAR(50),
  sri_activo BOOLEAN,
  horario_apertura TIME,
  horario_cierre TIME,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),

  score INTEGER,
  desglose_score JSONB,

  usuario_id_creador UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  fuente VARCHAR(50) CHECK (fuente IN ('google_places', 'manual', 'sri')),
  data_version INTEGER NOT NULL DEFAULT 1,

  fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_ultima_actualizacion TIMESTAMPTZ NOT NULL DEFAULT now(),

  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices para queries frecuentes
CREATE UNIQUE INDEX idx_prospects_nombre_dirección ON prospects(nombre, dirección) WHERE activo = true;
CREATE INDEX idx_prospects_usuario_creador_score ON prospects(usuario_id_creador, score DESC);
CREATE INDEX idx_prospects_tipo_negocio_score ON prospects(tipo_negocio, score DESC);
CREATE INDEX idx_prospects_fecha_actualización ON prospects(fecha_ultima_actualizacion DESC);
CREATE INDEX idx_prospects_sri_activo ON prospects(sri_activo);
CREATE INDEX idx_prospects_score ON prospects(score DESC);
CREATE INDEX idx_prospects_zona_geográfica ON prospects(latitude, longitude);

-- RLS: todos pueden leer (es tabla global), solo creador puede actualizar
ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospects_select_all" ON prospects
  FOR SELECT
  USING (true);

CREATE POLICY "prospects_update_creador" ON prospects
  FOR UPDATE
  USING (auth.uid() = usuario_id_creador OR (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin')
  WITH CHECK (auth.uid() = usuario_id_creador OR (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin');

COMMIT;

-- ============================================================================
-- Migration 4: Create prospect_versions table (Audit trail)
-- Date: 2026-04-22
-- Description: Immutable history of prospect data changes for comparison/audit

BEGIN;

CREATE TABLE IF NOT EXISTS prospect_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,

  -- All prospect data snapshot
  nombre VARCHAR(255),
  dirección VARCHAR(500),
  teléfono VARCHAR(20),
  website VARCHAR(500),
  https BOOLEAN,
  facebook_instagram VARCHAR(500),
  google_rating DECIMAL(3,1),
  google_reviews_count INTEGER,
  tipo_negocio VARCHAR(100),
  empleados_estimados VARCHAR(50),
  sri_activo BOOLEAN,
  horario_apertura TIME,
  horario_cierre TIME,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),

  score INTEGER,
  desglose_score JSONB,

  -- Version metadata
  usuario_actualizo UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  razon VARCHAR(100) CHECK (razon IN ('búsqueda_inicial', 'refresh', 'manual', 'actualización')),
  cambios_json JSONB,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para acceso rápido a versiones de un prospecto
CREATE INDEX idx_prospect_versions_prospect_version ON prospect_versions(prospect_id, version_number DESC);
CREATE INDEX idx_prospect_versions_timestamp ON prospect_versions(created_at DESC);

-- RLS: todos pueden leer (es auditoria)
ALTER TABLE prospect_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospect_versions_select_all" ON prospect_versions
  FOR SELECT
  USING (true);

COMMIT;

-- ============================================================================
-- Migration 5: Create searches table
-- Date: 2026-04-22
-- Description: Audit trail of all searches performed by users

BEGIN;

CREATE TABLE IF NOT EXISTS searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  query TEXT,
  zona VARCHAR(100),
  tipo_negocio VARCHAR(100),
  nombre VARCHAR(255),
  empleados_range VARCHAR(50),
  presencia_web VARCHAR(50),

  cantidad_resultados_pedida INTEGER,
  cantidad_resultados_obtenida INTEGER,

  costo_búsqueda_real DECIMAL(10,4),
  costo_empresas_real DECIMAL(10,4),
  costo_total_real DECIMAL(10,4),

  costo_búsqueda_venta DECIMAL(10,4),
  costo_empresas_venta DECIMAL(10,4),
  costo_total_venta DECIMAL(10,4),

  estado VARCHAR(50) CHECK (estado IN ('exitosa', 'error', 'cancelada')),
  error_message TEXT,

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_searches_usuario_timestamp ON searches(usuario_id, timestamp DESC);
CREATE INDEX idx_searches_estado ON searches(estado);

-- RLS: cada user solo ve sus búsquedas
ALTER TABLE searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "searches_select_own" ON searches
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "searches_insert_own" ON searches
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

COMMIT;

-- ============================================================================
-- Migration 6: Create saved_prospects table
-- Date: 2026-04-22
-- Description: User favorites and follow-up tracking

BEGIN;

CREATE TABLE IF NOT EXISTS saved_prospects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,

  estado VARCHAR(50) NOT NULL DEFAULT 'Nuevo' CHECK (estado IN ('Nuevo', 'Contactado', 'Interesado', 'Rechazado', 'Ganado')),
  notas TEXT,
  fecha_próxima_acción DATE,
  fecha_contacto TIMESTAMPTZ,
  monto_acordado DECIMAL(12,2),

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_saved_prospects_usuario_prospect ON saved_prospects(usuario_id, prospect_id);
CREATE INDEX idx_saved_prospects_usuario_estado ON saved_prospects(usuario_id, estado);
CREATE INDEX idx_saved_prospects_usuario_timestamp ON saved_prospects(usuario_id, timestamp DESC);

-- RLS: cada user solo ve sus guardados
ALTER TABLE saved_prospects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "saved_prospects_select_own" ON saved_prospects
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "saved_prospects_insert_own" ON saved_prospects
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "saved_prospects_update_own" ON saved_prospects
  FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "saved_prospects_delete_own" ON saved_prospects
  FOR DELETE
  USING (auth.uid() = usuario_id);

COMMIT;

-- ============================================================================
-- Migration 7: Create search_parameters table
-- Date: 2026-04-22
-- Description: Saved search queries for quick reuse

BEGIN;

CREATE TABLE IF NOT EXISTS search_parameters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre_búsqueda VARCHAR(255) NOT NULL,
  parameters JSONB NOT NULL,
  resultados_por_defecto INTEGER DEFAULT 20,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_search_parameters_usuario_timestamp ON search_parameters(usuario_id, timestamp DESC);

-- RLS: cada user solo ve sus búsquedas guardadas
ALTER TABLE search_parameters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "search_parameters_select_own" ON search_parameters
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "search_parameters_insert_own" ON search_parameters
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "search_parameters_update_own" ON search_parameters
  FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "search_parameters_delete_own" ON search_parameters
  FOR DELETE
  USING (auth.uid() = usuario_id);

COMMIT;

-- ============================================================================
-- Migration 8: Create cost_logs table
-- Date: 2026-04-22
-- Description: Detailed audit trail of all costs (real vs venta)

BEGIN;

CREATE TABLE IF NOT EXISTS cost_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  búsqueda_id UUID REFERENCES searches(id) ON DELETE SET NULL,

  tipo_operacion VARCHAR(50) NOT NULL CHECK (tipo_operacion IN ('búsqueda', 'empresa', 'guardado', 'refresh')),
  cantidad INTEGER NOT NULL,

  costo_unitario_real DECIMAL(10,4),
  costo_unitario_venta DECIMAL(10,4),
  costo_total_real DECIMAL(10,4),
  costo_total_venta DECIMAL(10,4),

  margen_absoluto DECIMAL(10,4),
  margen_porcentaje DECIMAL(5,2),

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cost_logs_usuario_timestamp ON cost_logs(usuario_id, timestamp DESC);
CREATE INDEX idx_cost_logs_tipo_operacion ON cost_logs(tipo_operacion);

-- RLS: cada user solo ve sus costos
ALTER TABLE cost_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cost_logs_select_own" ON cost_logs
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "cost_logs_insert_own" ON cost_logs
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

COMMIT;

-- ============================================================================
-- Migration 9: Create prospect_access_log table
-- Date: 2026-04-22
-- Description: Audit of how prospects are accessed (cache vs API)

BEGIN;

CREATE TABLE IF NOT EXISTS prospect_access_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  búsqueda_id UUID REFERENCES searches(id) ON DELETE SET NULL,

  origen VARCHAR(50) NOT NULL CHECK (origen IN ('búsqueda_nueva', 'caché', 'refresh')),
  costo_real DECIMAL(10,4),
  costo_venta DECIMAL(10,4),

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_prospect_access_log_prospect ON prospect_access_log(prospect_id);
CREATE INDEX idx_prospect_access_log_usuario_timestamp ON prospect_access_log(usuario_id, timestamp DESC);
CREATE INDEX idx_prospect_access_log_origen ON prospect_access_log(origen);

-- RLS: todos pueden leer (es auditoría)
ALTER TABLE prospect_access_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospect_access_log_select_all" ON prospect_access_log
  FOR SELECT
  USING (true);

COMMIT;

-- ============================================================================
-- Migration 10: Create admin_settings table
-- Date: 2026-04-22
-- Description: Global configuration for operational costs and system settings

BEGIN;

CREATE TABLE IF NOT EXISTS admin_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave VARCHAR(255) UNIQUE NOT NULL,
  valor VARCHAR(500) NOT NULL,
  descripcion TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Insert default settings
INSERT INTO admin_settings (clave, valor, descripcion) VALUES
  ('costo_google_places_per_result', '0.0034', 'Costo real operacional por resultado Google Places'),
  ('costo_empresa_real', '0.0020', 'Costo real operacional por empresa consultada'),
  ('costo_sri_per_query', '0.001', 'Costo real operacional por consulta SRI'),
  ('costo_refresh_empresa', '0.0020', 'Costo real operacional para actualizar datos de empresa'),
  ('refresh_interval_days', '60', 'Intervalo mínimo entre refreshes (en días)');

-- RLS: READ-ONLY tabla (evitar escalada de privs vía API)
-- IMPORTANTE: No hay policies de UPDATE/INSERT/DELETE (implícitamente denegado)
-- Cualquier cambio en costos operacionales DEBE hacerse via SQL migration (DBA/Mateo)
-- Razón: Evita que admins manipulen costos para alterar billing/margen en tiempo real
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_settings_admin_select_only" ON admin_settings
  FOR SELECT
  USING ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin');

COMMIT;

-- ============================================================================
-- Migration 11: Create user_subscriptions table
-- Date: 2026-04-22
-- Description: Track user plan assignments over time

BEGIN;

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES billing_plans(id),

  fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_fin TIMESTAMPTZ,
  estado VARCHAR(50) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'cancelado')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para obtener suscripción activa de un usuario
CREATE INDEX idx_user_subscriptions_usuario_activo ON user_subscriptions(usuario_id, estado) WHERE estado = 'activo';
CREATE INDEX idx_user_subscriptions_timestamp ON user_subscriptions(created_at DESC);

-- RLS: user ve su suscripción, admin ve todas
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_subscriptions_select_own_or_admin" ON user_subscriptions
  FOR SELECT
  USING (
    auth.uid() = usuario_id OR
    (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

COMMIT;

-- ============================================================================
-- END OF MIGRATIONS
-- ============================================================================
