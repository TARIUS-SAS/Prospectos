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
  ('costo_google_places_per_result', '0.0034', 'Costo real operacional por resultado Google Places'),
  ('costo_empresa_real', '0.0020', 'Costo real operacional por empresa consultada'),
  ('costo_sri_per_query', '0.001', 'Costo real operacional por consulta SRI'),
  ('costo_refresh_empresa', '0.0020', 'Costo real operacional para actualizar datos de empresa'),
  ('refresh_interval_days', '60', 'Intervalo mínimo entre refreshes (en días)');

-- RLS: READ-ONLY tabla (evitar escalada de privs vía API)
-- IMPORTANTE: No hay policies de UPDATE/INSERT/DELETE (implícitamente denegado)
-- Cualquier cambio en costos operacionales DEBE hacerse via SQL migration (DBA/Mateo)
-- Razón: Evita que admins manipulen costos para alterar billing/margen en tiempo real
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_settings_admin_select_only" ON admin_settings
  FOR SELECT
  USING (EXISTS(SELECT 1 FROM users_metadata WHERE id = auth.uid() AND role = 'admin'));

-- Verificación de seguridad: Si necesitas AGREGAR un nuevo costo operacional
-- (ej: 'costo_nuevo_servicio'), crea una nueva migration con INSERT, no lo hagas vía API
-- Ejemplo: INSERT INTO admin_settings (clave, valor, descripcion) VALUES ('costo_nuevo_servicio', '0.005', 'desc');

COMMIT;

-- Down
-- DROP TABLE admin_settings;
