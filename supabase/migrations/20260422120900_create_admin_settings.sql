-- Migration: Create admin_settings table
-- Date: 2026-04-22
-- Description: Global configuration for operational costs and system settings

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS admin_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clave VARCHAR(255) UNIQUE NOT NULL,
  valor VARCHAR(500) NOT NULL,
  descripcion TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Insert default settings
INSERT INTO admin_settings (clave, valor, descripcion) VALUES
  ('costo_google_places_per_result', '0.0034', 'Costo real por resultado Google Places'),
  ('costo_sri_per_query', '0.001', 'Costo real por consulta SRI'),
  ('costo_refresh_empresa', '0.0020', 'Costo real para actualizar datos de empresa'),
  ('refresh_interval_days', '60', 'Intervalo mínimo entre refreshes (en días)');

-- RLS: READ-ONLY para admins (evitar escalada de privs)
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_settings_admin_only_select" ON admin_settings
  FOR SELECT
  USING ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin');

-- Nota: Sin policy de UPDATE/INSERT/DELETE (implícitamente denegado)
-- Los cambios de costos deben hacerse directamente en BD por DBA/Mateo, no por API

COMMIT;

-- Down
-- DROP TABLE admin_settings;
