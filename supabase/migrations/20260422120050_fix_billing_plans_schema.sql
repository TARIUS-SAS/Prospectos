-- Migration: Fix billing_plans table schema
-- Date: 2026-04-22
-- Description: Add missing columns to existing billing_plans table

BEGIN;

ALTER TABLE billing_plans
ADD COLUMN IF NOT EXISTS búsquedas_max_mes INTEGER,
ADD COLUMN IF NOT EXISTS costo_búsqueda_venta DECIMAL(10,4),
ADD COLUMN IF NOT EXISTS costo_empresa_venta DECIMAL(10,4),
ADD COLUMN IF NOT EXISTS costo_guardado_venta DECIMAL(10,4),
ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- Set defaults if needed
UPDATE billing_plans
SET búsquedas_max_mes = COALESCE(búsquedas_max_mes, 20),
    costo_búsqueda_venta = COALESCE(costo_búsqueda_venta, 0.50),
    costo_empresa_venta = COALESCE(costo_empresa_venta, 0.05),
    costo_guardado_venta = COALESCE(costo_guardado_venta, 0.10),
    activo = COALESCE(activo, true),
    created_at = COALESCE(created_at, now()),
    updated_at = COALESCE(updated_at, now());

-- Create index on activo column
CREATE INDEX IF NOT EXISTS idx_billing_plans_activo ON billing_plans(activo);

COMMIT;
