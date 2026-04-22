-- Migration: Create search_parameters table
-- Date: 2026-04-22
-- Description: Saved search queries for quick reuse

-- Up
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

-- Down
-- DROP TABLE search_parameters;
