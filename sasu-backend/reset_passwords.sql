-- Clear all data and reset database
-- This will allow DataInitializationService to recreate users with correct passwords
-- Run this on the VPS: sqlite3 /var/lib/sasu/sasu.db < reset_passwords.sql

-- Delete all data (in order due to foreign keys)
DELETE FROM expenses;
DELETE FROM incomes;
DELETE FROM liabilities;
DELETE FROM insurance;
DELETE FROM assets;
DELETE FROM users;

-- Reset autoincrement counters
DELETE FROM sqlite_sequence;

-- Verify tables are empty
SELECT 'Users count:', COUNT(*) FROM users;
SELECT 'Assets count:', COUNT(*) FROM assets;
SELECT 'Insurance count:', COUNT(*) FROM insurance;
SELECT 'Liabilities count:', COUNT(*) FROM liabilities;
SELECT 'Incomes count:', COUNT(*) FROM incomes;
SELECT 'Expenses count:', COUNT(*) FROM expenses;

-- After running this, restart the Spring Boot application
-- It will automatically initialize with:
-- Username: admin, Password: admin123
-- Username: wife, Password: wife123
-- Username: daughter, Password: daughter123

