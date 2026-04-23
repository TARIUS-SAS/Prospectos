-- ============================================
-- PROSPECTOR WEB v2 - MIGRACION COMPLETA
-- Ejecutar TODO en Supabase SQL Editor
-- ============================================

-- DROP ALL (si necesitas limpiar)
DROP TABLE IF EXISTS saved_prospects CASCADE;
DROP TABLE IF EXISTS prospects CASCADE;
DROP TABLE IF EXISTS searches CASCADE;
DROP TABLE IF EXISTS sri_cache CASCADE;
DROP TABLE IF EXISTS users_metadata CASCADE;

-- ============================================
-- 1. USERS METADATA
-- ============================================
CREATE TABLE users_metadata (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  company TEXT,
  default_zone VARCHAR(100),
  default_business_type VARCHAR(100),
  max_searches_daily INT DEFAULT 100,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE users_metadata ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_see_own_metadata" ON users_metadata FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "users_update_own_metadata" ON users_metadata FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 2. SEARCHES (Audit trail)
-- ============================================
CREATE TABLE searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  zona VARCHAR(100),
  tipo_negocio VARCHAR(100),
  palabra_clave VARCHAR(255),
  empleados_range VARCHAR(50),
  presencia_web VARCHAR(50),
  sri_activo BOOLEAN DEFAULT true,
  cantidad_resultados INT,
  score_promedio DECIMAL(5,2),
  created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_searches_user_created ON searches(user_id, created_at DESC);
ALTER TABLE searches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_see_own_searches" ON searches FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "users_insert_own_searches" ON searches FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 3. PROSPECTS (Main data - shared)
-- ============================================
CREATE TABLE prospects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_id UUID REFERENCES searches(id) ON DELETE SET NULL,
  nombre VARCHAR(255) NOT NULL,
  direccion VARCHAR(500),
  telefono VARCHAR(20),
  website VARCHAR(500),
  email VARCHAR(255),
  zona VARCHAR(100),
  tipo_negocio VARCHAR(100),
  ruc VARCHAR(13),
  sri_activo BOOLEAN,
  google_rating DECIMAL(3,1),
  google_reviews INT DEFAULT 0,
  empleados_estimado VARCHAR(50),
  presencia_web VARCHAR(50),
  has_facebook BOOLEAN DEFAULT false,
  has_instagram BOOLEAN DEFAULT false,
  score INT,
  score_breakdown JSONB,
  created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_prospects_search ON prospects(search_id);
CREATE INDEX idx_prospects_score ON prospects(score DESC);
CREATE INDEX idx_prospects_ruc ON prospects(ruc);
CREATE INDEX idx_prospects_nombre ON prospects(nombre);

ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "everyone_see_prospects" ON prospects FOR SELECT USING (true);

-- ============================================
-- 4. SAVED PROSPECTS (CRM)
-- ============================================
CREATE TABLE saved_prospects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prospect_id UUID NOT NULL REFERENCES prospects(id) ON DELETE CASCADE,
  estado VARCHAR(50) DEFAULT 'Nuevo' CHECK (estado IN ('Nuevo', 'Contactado', 'Interesado', 'Ganado')),
  notas TEXT,
  proxima_accion DATE,
  monto_acordado DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE saved_prospects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_manage_own_saved" ON saved_prospects FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_saved_user ON saved_prospects(user_id);
CREATE INDEX idx_saved_estado ON saved_prospects(user_id, estado);
CREATE INDEX idx_saved_proxima_accion ON saved_prospects(proxima_accion);

-- ============================================
-- 5. SRI CACHE (Offline data)
-- ============================================
CREATE TABLE sri_cache (
  ruc VARCHAR(13) PRIMARY KEY,
  razon_social VARCHAR(255),
  actividad_economica VARCHAR(500),
  sri_estado VARCHAR(50),
  provincia VARCHAR(100),
  canton VARCHAR(100),
  cached_at TIMESTAMP DEFAULT now(),
  expires_at TIMESTAMP DEFAULT now() + INTERVAL '60 days'
);

CREATE INDEX idx_sri_cache_expires ON sri_cache(expires_at);

-- ============================================
-- FIN MIGRACION
-- ============================================
