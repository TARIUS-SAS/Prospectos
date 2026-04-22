-- Migration: Create saved_prospects table
-- Date: 2026-04-22
-- Description: User favorites and follow-up tracking

-- Up
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

-- Down
-- DROP TABLE saved_prospects;
