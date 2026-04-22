-- Migration: Create prospect_versions table (Audit trail)
-- Date: 2026-04-22
-- Description: Immutable history of prospect data changes for comparison/audit

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS prospect_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,

  -- All prospect data snapshot (same fields as prospects)
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

  -- Version metadata
  usuario_actualizo UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  razon TEXT,
  cambios_json JSONB,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(prospect_id, version_number)
);

-- Índice para acceso rápido a versiones de un prospecto
CREATE INDEX idx_prospect_versions_prospect_version ON prospect_versions(prospect_id, version_number DESC);
CREATE INDEX idx_prospect_versions_timestamp ON prospect_versions(created_at DESC);

-- RLS: usuarios solo ven versiones de prospectos que les pertenecen
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

COMMIT;

-- Down
-- DROP TABLE prospect_versions;
