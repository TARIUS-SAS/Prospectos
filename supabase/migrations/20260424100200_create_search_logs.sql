-- Migration: Create search_logs table
-- Date: 2026-04-24
-- Description: Audit trail for all searches performed

BEGIN;

CREATE TABLE IF NOT EXISTS search_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Search parameters (snapshot)
  query_json JSONB NOT NULL,
  zona VARCHAR(100),
  tipo_negocio VARCHAR(100),
  palabra_clave VARCHAR(255),
  empleados_range VARCHAR(50),
  presencia_web VARCHAR(50),
  sri_activo BOOLEAN,

  -- Results summary
  cantidad_solicitada INTEGER DEFAULT 20,
  cantidad_obtenida INTEGER,
  tiempo_ejecucion_ms INTEGER,

  -- Status tracking
  estado VARCHAR(50) CHECK (estado IN ('exitosa', 'parcial', 'error')),
  mensaje_error VARCHAR(500),

  -- Source & metadata
  fuente VARCHAR(50) CHECK (fuente IN ('google_places', 'local_db', 'sri')),
  user_agent VARCHAR(500),
  ip_address INET,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices para queries
CREATE INDEX idx_search_logs_usuario_id ON search_logs(usuario_id);
CREATE INDEX idx_search_logs_usuario_created ON search_logs(usuario_id, created_at DESC);
CREATE INDEX idx_search_logs_estado ON search_logs(estado);
CREATE INDEX idx_search_logs_created_at ON search_logs(created_at DESC);
CREATE INDEX idx_search_logs_tipo_negocio ON search_logs(tipo_negocio);

-- RLS: cada usuario ve solo sus búsquedas, admins ven todo
ALTER TABLE search_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "search_logs_select_own" ON search_logs
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

CREATE POLICY "search_logs_insert_own" ON search_logs
  FOR INSERT
  WITH CHECK (usuario_id = auth.uid());

COMMIT;

-- Down
-- DROP TABLE search_logs;
