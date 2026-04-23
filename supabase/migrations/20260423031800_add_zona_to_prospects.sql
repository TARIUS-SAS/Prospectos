-- Migration: Add zona column to prospects
-- Date: 2026-04-23
-- Description: Add geographic zone column for search filtering

BEGIN;

ALTER TABLE prospects
ADD COLUMN zona VARCHAR(100);

CREATE INDEX idx_prospects_zona ON prospects(zona);

COMMIT;

-- Down
-- ALTER TABLE prospects DROP COLUMN zona;
-- DROP INDEX idx_prospects_zona;
