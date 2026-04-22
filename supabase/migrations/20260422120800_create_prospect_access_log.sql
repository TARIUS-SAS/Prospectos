-- Migration: Create prospect_access_log table
-- Date: 2026-04-22
-- Description: Audit of how prospects are accessed (cache vs API)

-- Up
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

-- Down
-- DROP TABLE prospect_access_log;
