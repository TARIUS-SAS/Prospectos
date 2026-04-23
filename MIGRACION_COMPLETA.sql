-- ========================================
-- MIGRACION COMPLETA PROSPECTOR WEB
-- Ejecutar TODO junto en Supabase SQL Editor
-- ========================================

-- PASO 1: Eliminar todas las tablas existentes (en orden de dependencias)
DROP TABLE IF EXISTS prospect_versions CASCADE;
DROP TABLE IF EXISTS saved_prospects CASCADE;
DROP TABLE IF EXISTS searches CASCADE;
DROP TABLE IF EXISTS admin_config CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;
DROP TABLE IF EXISTS prospects CASCADE;
DROP TABLE IF EXISTS users_metadata CASCADE;
DROP TABLE IF EXISTS billing_plans CASCADE;

-- PASO 2: Crear billing_plans (si no existe)
CREATE TABLE IF NOT EXISTS billing_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(100) UNIQUE NOT NULL,
  descripcion TEXT,
  costo_búsqueda_venta DECIMAL(10,4),
  costo_empresa_venta DECIMAL(10,4),
  costo_por_actualización DECIMAL(10,4),
  limite_búsquedas_diarias INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO billing_plans (nombre, descripcion, costo_búsqueda_venta, costo_empresa_venta, costo_por_actualización, limite_búsquedas_diarias)
VALUES
  ('Starter', 'Plan básico', 0.50, 0.05, 0.10, 20),
  ('Professional', 'Plan profesional', 0.35, 0.03, 0.08, 50),
  ('Enterprise', 'Plan empresarial', 0.20, 0.02, 0.05, 200)
ON CONFLICT DO NOTHING;

-- PASO 3: Crear users_metadata
CREATE TABLE IF NOT EXISTS users_metadata (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES billing_plans(id),
  role VARCHAR(50) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  búsquedas_max_por_día INTEGER NOT NULL DEFAULT 20,
  resultados_por_defecto INTEGER NOT NULL DEFAULT 20,
  fecha_alta TIMESTAMPTZ NOT NULL DEFAULT now(),
  estado VARCHAR(50) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
  notas_internas TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE users_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_metadata_own_or_admin" ON users_metadata
  FOR SELECT
  USING (
    auth.uid() = id OR
    EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "users_metadata_update_own" ON users_metadata
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "users_metadata_update_admin" ON users_metadata
  FOR UPDATE
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

CREATE INDEX IF NOT EXISTS idx_users_metadata_plan_id ON users_metadata(plan_id);
CREATE INDEX IF NOT EXISTS idx_users_metadata_estado ON users_metadata(estado);
CREATE INDEX IF NOT EXISTS idx_users_metadata_role ON users_metadata(role);

-- PASO 4: Crear prospects
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

CREATE UNIQUE INDEX IF NOT EXISTS idx_prospects_nombre_dirección ON prospects(nombre, dirección) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_prospects_usuario_creador_score ON prospects(usuario_id_creador, score DESC);
CREATE INDEX IF NOT EXISTS idx_prospects_tipo_negocio_score ON prospects(tipo_negocio, score DESC);
CREATE INDEX IF NOT EXISTS idx_prospects_fecha_actualización ON prospects(fecha_ultima_actualizacion DESC);
CREATE INDEX IF NOT EXISTS idx_prospects_sri_activo ON prospects(sri_activo);
CREATE INDEX IF NOT EXISTS idx_prospects_score ON prospects(score DESC);
CREATE INDEX IF NOT EXISTS idx_prospects_zona_geográfica ON prospects(latitude, longitude);

ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospects_select_all" ON prospects
  FOR SELECT
  USING (true);

CREATE POLICY "prospects_update_creador" ON prospects
  FOR UPDATE
  USING (auth.uid() = usuario_id_creador OR EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (auth.uid() = usuario_id_creador OR EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

-- PASO 5: Crear searches
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
  estado VARCHAR(50) CHECK (estado IN ('exitosa', 'error', 'cancelada', 'en_progreso')),
  error_message TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_searches_usuario_timestamp ON searches(usuario_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_searches_estado ON searches(estado);

ALTER TABLE searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "searches_select_own" ON searches
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "searches_insert_own" ON searches
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- PASO 6: Crear saved_prospects
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

CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_prospects_usuario_prospect ON saved_prospects(usuario_id, prospect_id);
CREATE INDEX IF NOT EXISTS idx_saved_prospects_usuario_estado ON saved_prospects(usuario_id, estado);
CREATE INDEX IF NOT EXISTS idx_saved_prospects_usuario_timestamp ON saved_prospects(usuario_id, timestamp DESC);

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

-- PASO 7: Crear prospect_versions
CREATE TABLE IF NOT EXISTS prospect_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  business_name TEXT,
  category TEXT,
  address TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  website_status TEXT,
  has_https BOOLEAN,
  facebook_instagram TEXT,
  google_rating DECIMAL(3,1),
  google_reviews_count INTEGER,
  estimated_employees TEXT,
  sri_active BOOLEAN,
  opening_time TIME,
  closing_time TIME,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  score INTEGER,
  score_breakdown JSONB,
  usuario_actualizo UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  razon TEXT,
  cambios_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(prospect_id, version_number)
);

CREATE INDEX IF NOT EXISTS idx_prospect_versions_prospect_version ON prospect_versions(prospect_id, version_number DESC);
CREATE INDEX IF NOT EXISTS idx_prospect_versions_timestamp ON prospect_versions(created_at DESC);

ALTER TABLE prospect_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospect_versions_select_own" ON prospect_versions
  FOR SELECT
  USING (
    prospect_id IN (
      SELECT id FROM prospects WHERE usuario_id_creador = auth.uid()
    ) OR
    EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "prospect_versions_insert_own" ON prospect_versions
  FOR INSERT
  WITH CHECK (
    usuario_actualizo = auth.uid() AND
    prospect_id IN (
      SELECT id FROM prospects WHERE usuario_id_creador = auth.uid()
    )
  );

-- PASO 8: Crear admin_settings (READ-ONLY)
CREATE TABLE IF NOT EXISTS admin_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave VARCHAR(255) UNIQUE NOT NULL,
  valor VARCHAR(500) NOT NULL,
  descripcion TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

INSERT INTO admin_settings (clave, valor, descripcion) VALUES
  ('costo_google_places_per_result', '0.0034', 'Costo real operacional por resultado Google Places'),
  ('costo_empresa_real', '0.0020', 'Costo real operacional por empresa consultada'),
  ('costo_sri_per_query', '0.001', 'Costo real operacional por consulta SRI'),
  ('costo_refresh_empresa', '0.0020', 'Costo real operacional para actualizar datos de empresa'),
  ('refresh_interval_days', '60', 'Intervalo mínimo entre refreshes (en días)')
ON CONFLICT DO NOTHING;

ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_settings_admin_select_only" ON admin_settings
  FOR SELECT
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

-- PASO 9: Crear admin_config (EDITABLE)
CREATE TABLE IF NOT EXISTS admin_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave VARCHAR(255) UNIQUE NOT NULL,
  valor DECIMAL(10,4) NOT NULL,
  descripcion TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

INSERT INTO admin_config (clave, valor, descripcion) VALUES
  ('costo_por_búsqueda', 0.50, 'Precio de venta por búsqueda'),
  ('costo_por_actualización', 0.10, 'Precio de venta por actualización de prospecto'),
  ('margen_mínimo_percent', 30.0, 'Margen mínimo porcentual permitido')
ON CONFLICT DO NOTHING;

ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_config_select_admin_only" ON admin_config
  FOR SELECT
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "admin_config_update_admin_only" ON admin_config
  FOR UPDATE
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

-- ========================================
-- FIN DE MIGRACION
-- ========================================
