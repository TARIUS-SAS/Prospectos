-- Migration: Add Google Places cost tracking
-- Date: 2026-04-24
-- Description: Track Google Places API costs per prospect and overall usage

BEGIN;

-- Add cost column to prospects
ALTER TABLE prospects
ADD COLUMN IF NOT EXISTS google_places_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS google_places_cost DECIMAL(8,4),
ADD COLUMN IF NOT EXISTS google_places_updated_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_prospects_google_places_id ON prospects(google_places_id);

-- Create API costs audit table
CREATE TABLE IF NOT EXISTS api_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

  -- API details
  tipo_api VARCHAR(50) NOT NULL CHECK (tipo_api IN ('google_places', 'sri')),
  operation VARCHAR(100),

  -- Cost info
  costo_usd DECIMAL(8,4),
  costo_creditos INTEGER,

  -- Request details
  place_id VARCHAR(255),
  business_name VARCHAR(255),
  request_data JSONB,

  -- Response
  response_code INTEGER,
  error_message VARCHAR(500),

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices
CREATE INDEX idx_api_costs_usuario_id ON api_costs(usuario_id);
CREATE INDEX idx_api_costs_tipo_api ON api_costs(tipo_api);
CREATE INDEX idx_api_costs_usuario_fecha ON api_costs(usuario_id, created_at DESC);
CREATE INDEX idx_api_costs_created_at ON api_costs(created_at DESC);

-- RLS: cada usuario ve solo sus costos, admins ven todo
ALTER TABLE api_costs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "api_costs_select_own" ON api_costs
  FOR SELECT
  USING (
    usuario_id = auth.uid()
    OR
    EXISTS(
      SELECT 1 FROM users_metadata
      WHERE users_metadata.id = auth.uid()
      AND users_metadata.role = 'admin'
    )
  );

CREATE POLICY "api_costs_insert_own" ON api_costs
  FOR INSERT
  WITH CHECK (usuario_id = auth.uid() OR usuario_id IS NULL);

COMMIT;

-- Down
-- ALTER TABLE prospects DROP COLUMN IF EXISTS google_places_id;
-- ALTER TABLE prospects DROP COLUMN IF EXISTS google_places_cost;
-- ALTER TABLE prospects DROP COLUMN IF EXISTS google_places_updated_at;
-- DROP TABLE IF EXISTS api_costs;
