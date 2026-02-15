-- Migration: Add LOAN_EMI to expense categories
-- Run this on your production SQLite database

-- SQLite doesn't support ALTER TABLE to modify constraints
-- So we need to recreate the table

-- Step 1: Create new table with updated constraint
CREATE TABLE expenses_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    active BOOLEAN NOT NULL,
    amount DECIMAL(38,2) NOT NULL,
    category VARCHAR(255) NOT NULL CHECK (category IN ('FOOD','UTILITIES','TRANSPORTATION','EDUCATION','HEALTHCARE','ENTERTAINMENT','SHOPPING','HOUSING','INSURANCE','LOAN_EMI','SAVINGS','OTHER')),
    description VARCHAR(255),
    frequency VARCHAR(255) NOT NULL CHECK (frequency IN ('MONTHLY','QUARTERLY','YEARLY','ONE_TIME')),
    name VARCHAR(255) NOT NULL,
    start_date DATE,
    is_need INTEGER DEFAULT 1
);

-- Step 2: Copy existing data
INSERT INTO expenses_new (id, active, amount, category, description, frequency, name, start_date, is_need)
SELECT id, active, amount, category, description, frequency, name, start_date, is_need FROM expenses;

-- Step 3: Drop old table
DROP TABLE expenses;

-- Step 4: Rename new table to original name
ALTER TABLE expenses_new RENAME TO expenses;

-- Verify the change
SELECT sql FROM sqlite_master WHERE type='table' AND name='expenses';

