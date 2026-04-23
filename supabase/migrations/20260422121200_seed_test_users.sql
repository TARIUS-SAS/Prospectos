-- Migration: Seed test users with roles
-- Date: 2026-04-22
-- Description: Insert test users (admin and regular) into users_metadata
-- MANUAL STEP REQUIRED: Create these users in Supabase Auth first

-- Up
BEGIN;

-- NOTE: The following INSERT is commented out because test users don't exist yet in auth.users
-- To use this, first create users in Supabase Auth dashboard, then replace the UUIDs below
-- and uncomment these lines:

-- UPDATE: Replace these UUIDs with actual UUIDs after creating users in Auth dashboard
-- To find UUIDs, go to Supabase dashboard > Authentication > Users, copy the ID

-- Example UUIDs (replace with real values):
-- Admin user UUID: 11111111-1111-1111-1111-111111111111
-- Regular user UUID: 22222222-2222-2222-2222-222222222222

-- INSERT INTO users_metadata (id, role, búsquedas_max_por_día, resultados_por_defecto)
-- VALUES
--   ('11111111-1111-1111-1111-111111111111', 'admin', 100, 50),
--   ('22222222-2222-2222-2222-222222222222', 'user', 20, 20)
-- ON CONFLICT (id) DO NOTHING;

COMMIT;

-- Down
-- DELETE FROM users_metadata WHERE id IN ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
