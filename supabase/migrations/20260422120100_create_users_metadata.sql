-- Migration: Create users_metadata table
-- Date: 2026-04-22
-- Description: User metadata linked to auth.users (plan, limits, settings)

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS users_metadata (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES billing_plans(id),
  búsquedas_max_por_día INTEGER NOT NULL DEFAULT 20,
  resultados_por_defecto INTEGER NOT NULL DEFAULT 20,
  fecha_alta TIMESTAMPTZ NOT NULL DEFAULT now(),
  estado VARCHAR(50) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
  notas_internas TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: cada usuario ve su propio metadata, admin ve todos
ALTER TABLE users_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_metadata_own_or_admin" ON users_metadata
  FOR SELECT
  USING (
    auth.uid() = id OR
    (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "users_metadata_update_own" ON users_metadata
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "users_metadata_update_admin" ON users_metadata
  FOR UPDATE
  USING ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin');

CREATE INDEX idx_users_metadata_plan_id ON users_metadata(plan_id);
CREATE INDEX idx_users_metadata_estado ON users_metadata(estado);

COMMIT;

-- Down
-- DROP TABLE users_metadata;
