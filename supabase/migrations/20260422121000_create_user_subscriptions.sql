-- Migration: Create user_subscriptions table
-- Date: 2026-04-22
-- Description: Track user plan assignments over time

-- Up
BEGIN;

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES billing_plans(id),

  fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT now(),
  fecha_fin TIMESTAMPTZ,
  estado VARCHAR(50) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'cancelado')),

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para obtener suscripción activa de un usuario
CREATE INDEX idx_user_subscriptions_usuario_activo ON user_subscriptions(usuario_id, estado) WHERE estado = 'activo';
CREATE INDEX idx_user_subscriptions_timestamp ON user_subscriptions(created_at DESC);

-- RLS: user ve su suscripción, admin ve todas
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_subscriptions_select_own_or_admin" ON user_subscriptions
  FOR SELECT
  USING (
    auth.uid() = usuario_id OR
    (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

COMMIT;

-- Down
-- DROP TABLE user_subscriptions;
