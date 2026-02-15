# Password Reset Guide for VPS

## Problem
The passwords in the database don't match the expected credentials.

## Solution Options

### Option 1: Clear Database and Let App Re-initialize (RECOMMENDED)

1. **Stop the application**:
   ```bash
   sudo systemctl stop sasu
   ```

2. **Clear the database**:
   ```bash
   sqlite3 /var/lib/sasu/sasu.db < /path/to/reset_passwords.sql
   ```
   
   Or manually:
   ```bash
   sqlite3 /var/lib/sasu/sasu.db
   DELETE FROM expenses;
   DELETE FROM incomes;
   DELETE FROM liabilities;
   DELETE FROM insurance;
   DELETE FROM assets;
   DELETE FROM users;
   DELETE FROM sqlite_sequence;
   .quit
   ```

3. **Start the application**:
   ```bash
   sudo systemctl start sasu
   ```

4. **Check logs to verify initialization**:
   ```bash
   sudo journalctl -u sasu -f
   ```
   
   Look for: "✅ Sample data initialized successfully!"

5. **Verify users were created**:
   ```bash
   sqlite3 /var/lib/sasu/sasu.db "SELECT username, fullName, role FROM users;"
   ```

### Option 2: Generate and Update Password Hashes

1. **On your local machine**, navigate to backend:
   ```bash
   cd D:\dev\repository\myproject\sasufamily\sasu-backend
   ```

2. **Compile and run the password generator**:
   ```bash
   mvn compile exec:java -Dexec.mainClass="com.sasu.family.util.PasswordHashGenerator"
   ```

3. **Copy the generated SQL UPDATE statements**

4. **Run on VPS**:
   ```bash
   sqlite3 /var/lib/sasu/sasu.db
   -- Paste the UPDATE statements here
   .quit
   ```

### Option 3: Quick Test with Direct SQL

Try this quick fix on the VPS to test if it's just a password issue:

```bash
sqlite3 /var/lib/sasu/sasu.db
UPDATE users SET active = 1 WHERE username = 'admin';
.quit
```

Then restart the app and try logging in again.

## Expected Credentials After Fix

- **Username**: admin | **Password**: admin123
- **Username**: wife | **Password**: wife123
- **Username**: daughter | **Password**: daughter123

## Verification

After any option, verify the API works:
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Should return a JSON with token, username, fullName, and role.

