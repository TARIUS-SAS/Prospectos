-- Migration: Create cost_logs table
-- Date: 2026-04-22
-- Description: Detailed audit trail of all costs (real vs venta)

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS cost_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  búsqueda_id UUID REFERENCES searches(id) ON DELETE SET NULL,

  tipo_operacion VARCHAR(50) NOT NULL CHECK (tipo_operacion IN ('búsqueda', 'empresa', 'guardado', 'refresh')),
  cantidad INTEGER NOT NULL,

  costo_unitario_real DECIMAL(10,4),
  costo_unitario_venta DECIMAL(10,4),
  costo_total_real DECIMAL(10,4),
  costo_total_venta DECIMAL(10,4),

  margen_absoluto DECIMAL(10,4),
  margen_porcentaje DECIMAL(5,2),

  timestamp TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cost_logs_usuario_timestamp ON cost_logs(usuario_id, timestamp DESC);
CREATE INDEX idx_cost_logs_tipo_operacion ON cost_logs(tipo_operacion);

-- RLS: cada user solo ve sus costos
ALTER TABLE cost_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cost_logs_select_own" ON cost_logs
  FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "cost_logs_insert_own" ON cost_logs
  FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

COMMIT;

-- Down
-- DROP TABLE cost_logs;
