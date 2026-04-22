-- Migration: Create searches table
-- Date: 2026-04-22
-- Description: Audit trail of all searches performed by users

-- Up
BEGIN;

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

  estado VARCHAR(50) CHECK (estado IN ('exitosa', 'error', 'cancelada')),
  error_message TEXT,

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_searches_usuario_timestamp ON searches(usuario_id, timestamp DESC);
CREATE INDEX idx_searches_estado ON searches(estado);

-- RLS: cada user solo ve sus búsquedas
ALTER TABLE searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "searches_select_own" ON searches
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "searches_insert_own" ON searches
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

COMMIT;

-- Down
-- DROP TABLE searches;
