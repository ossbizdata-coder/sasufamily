-- Add is_need column to expenses table
-- This column tracks whether an expense is a "Need" (essential) vs "Want" (discretionary)
-- Used for emergency fund calculation (needs-based expenses)

ALTER TABLE expenses ADD COLUMN is_need INTEGER DEFAULT 1;

-- Update existing records to mark as "Need" by default
UPDATE expenses SET is_need = 1 WHERE is_need IS NULL;

