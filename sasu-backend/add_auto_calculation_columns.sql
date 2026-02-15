-- Migration: Add auto-growth and auto-calculate columns
-- Date: 2026-02-15
-- Description: Adds columns to support automatic value calculations for assets and liabilities

-- Add purchaseDate and autoGrowth columns to assets table
ALTER TABLE assets ADD COLUMN purchase_date DATE;
ALTER TABLE assets ADD COLUMN auto_growth BOOLEAN DEFAULT FALSE NOT NULL;

-- Add autoCalculate column to liabilities table
ALTER TABLE liabilities ADD COLUMN auto_calculate BOOLEAN DEFAULT FALSE NOT NULL;

-- Update existing assets: Set autoGrowth = true for investment assets with growth rates
-- (Optional: Uncomment if you want to enable auto-growth for existing investment assets)
-- UPDATE assets SET auto_growth = TRUE WHERE is_investment = TRUE AND yearly_growth_rate IS NOT NULL;

