-- Migration: Create prospect_versions table (Audit trail)
-- Date: 2026-04-22
-- Description: Immutable history of prospect data changes for comparison/audit

-- Up
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

-- Down
-- DROP TABLE prospect_versions;
