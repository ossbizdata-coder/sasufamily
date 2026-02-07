-- Add is_liquid column to assets table
ALTER TABLE assets ADD COLUMN is_liquid INTEGER NOT NULL DEFAULT 0;

-- Verify the change
PRAGMA table_info(assets);

