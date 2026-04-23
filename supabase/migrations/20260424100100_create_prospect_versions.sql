-- Migration: Create prospect_versions table
-- Date: 2026-04-24
-- Description: Immutable version history for prospects (audit trail)

BEGIN;

CREATE TABLE IF NOT EXISTS prospect_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,

  -- All prospect state fields (immutable copy)
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
  zona VARCHAR(100),
  horario_apertura TIME,
  horario_cierre TIME,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),

  score INTEGER,
  desglose_score JSONB,

  -- Change tracking
  cambios_json JSONB,
  usuario_actualizo UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  razon VARCHAR(500),

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT unique_prospect_version UNIQUE(prospect_id, version_number)
);

-- Índices para queries
CREATE INDEX idx_prospect_versions_prospect_id ON prospect_versions(prospect_id);
CREATE INDEX idx_prospect_versions_prospect_id_version ON prospect_versions(prospect_id, version_number DESC);
CREATE INDEX idx_prospect_versions_usuario ON prospect_versions(usuario_actualizo);
CREATE INDEX idx_prospect_versions_created_at ON prospect_versions(created_at DESC);

-- RLS: todos pueden leer versiones de sus propios prospectos
ALTER TABLE prospect_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prospect_versions_select_own" ON prospect_versions
  FOR SELECT
  USING (
    EXISTS(
      SELECT 1 FROM saved_prospects
      WHERE saved_prospects.prospect_id = prospect_versions.prospect_id
      AND saved_prospects.usuario_id = auth.uid()
    )
    OR
    EXISTS(
      SELECT 1 FROM prospects
      WHERE prospects.id = prospect_versions.prospect_id
      AND prospects.usuario_id_creador = auth.uid()
    )
    OR
    EXISTS(
      SELECT 1 FROM users_metadata
      WHERE users_metadata.id = auth.uid()
      AND users_metadata.role = 'admin'
    )
  );

COMMIT;

-- Down
-- DROP TABLE prospect_versions;
