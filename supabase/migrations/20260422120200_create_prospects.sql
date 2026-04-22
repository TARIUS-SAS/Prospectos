-- Migration: Create prospects table (GLOBAL, shared across users)
-- Date: 2026-04-22
-- Description: Central repository of all prospects found (prevents duplication)

-- Up
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

-- Down
-- DROP TABLE prospects;
