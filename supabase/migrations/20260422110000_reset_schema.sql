-- ============================================
-- PROSPECTOR WEB - RESET: Drop all tables
-- ============================================
-- This migration cleans up conflicting tables
-- so subsequent migrations can create proper schema

BEGIN;

DROP TABLE IF EXISTS prospect_versions CASCADE;
DROP TABLE IF EXISTS saved_prospects CASCADE;
DROP TABLE IF EXISTS prospect_access_log CASCADE;
DROP TABLE IF EXISTS cost_logs CASCADE;
DROP TABLE IF EXISTS search_parameters CASCADE;
DROP TABLE IF EXISTS searches CASCADE;
DROP TABLE IF EXISTS prospects CASCADE;
DROP TABLE IF EXISTS sri_cache CASCADE;
DROP TABLE IF EXISTS user_subscriptions CASCADE;
DROP TABLE IF EXISTS admin_config CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;
DROP TABLE IF EXISTS billing_plans CASCADE;
DROP TABLE IF EXISTS users_metadata CASCADE;

COMMIT;
