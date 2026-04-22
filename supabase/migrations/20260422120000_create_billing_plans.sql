-- Migration: Create billing_plans table
-- Date: 2026-04-22
-- Description: Plans for user subscriptions (Starter, Professional, Enterprise)

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS billing_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  búsquedas_max_mes INTEGER,
  costo_búsqueda_venta DECIMAL(10,4) NOT NULL,
  costo_empresa_venta DECIMAL(10,4) NOT NULL,
  costo_guardado_venta DECIMAL(10,4) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Insert default plans
INSERT INTO billing_plans (nombre, descripcion, búsquedas_max_mes, costo_búsqueda_venta, costo_empresa_venta, costo_guardado_venta) VALUES
  ('Starter', '20 búsquedas por mes, ideal para prospectos iniciales', 20, 0.50, 0.05, 0.10),
  ('Professional', '100 búsquedas por mes, para equipos activos', 100, 0.30, 0.03, 0.07),
  ('Enterprise', 'Ilimitado, máxima prospección', NULL, 0.20, 0.02, 0.05);

CREATE INDEX idx_billing_plans_activo ON billing_plans(activo);

COMMIT;

-- Down (comentado, por si hay que revertir)
-- DROP TABLE billing_plans;
