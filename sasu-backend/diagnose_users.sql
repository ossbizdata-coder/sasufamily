-- Diagnostic script to check user data
-- Run: sqlite3 /var/lib/sasu/sasu.db < diagnose_users.sql

.headers on
.mode column

-- Show all user details
SELECT 'Current Users:' as Info;
SELECT id, familyId, username, fullName, role, active FROM users;

-- Check if passwords look like BCrypt hashes
SELECT 'Password Check:' as Info;
SELECT username,
       CASE
         WHEN password LIKE '$2a$%' THEN 'BCrypt hash (good)'
         ELSE 'Plain text or invalid (bad)'
       END as password_status,
       LENGTH(password) as password_length
FROM users;

-- Show user count
SELECT 'Total users:' as Info, COUNT(*) as count FROM users;

