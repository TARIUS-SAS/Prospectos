-- Migration: Create admin_config table
-- Date: 2026-04-22
-- Description: Editable admin configuration (costs, margins)

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS admin_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave VARCHAR(255) UNIQUE NOT NULL,
  valor DECIMAL(10,4) NOT NULL,
  descripcion TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Insert default config
INSERT INTO admin_config (clave, valor, descripcion) VALUES
  ('costo_por_búsqueda', 0.50, 'Precio de venta por búsqueda'),
  ('costo_por_actualización', 0.10, 'Precio de venta por actualización de prospecto'),
  ('margen_mínimo_percent', 30.0, 'Margen mínimo porcentual permitido')
ON CONFLICT (clave) DO NOTHING;

-- RLS: solo admins pueden leer y actualizar
ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_config_select_admin_only" ON admin_config
  FOR SELECT
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "admin_config_update_admin_only" ON admin_config
  FOR UPDATE
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

COMMIT;

-- Down
-- DROP TABLE admin_config;
