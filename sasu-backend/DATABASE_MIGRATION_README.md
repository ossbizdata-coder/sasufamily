# Database Migration: Add is_liquid Column to Assets

## Problem
The application was failing with error:
```
SQLITE_ERROR: no such column: a1_0.is_liquid
```

## Solution
The `is_liquid` column needs to be added to the `assets` table in the SQLite database.

## Migration Methods

### ✅ RECOMMENDED: Automatic Migration (Easiest)

Simply **restart your Spring Boot application**. The new `DatabaseMigration.java` component will automatically:
1. Check if the `is_liquid` column exists
2. Add it if it doesn't exist
3. Mark existing CASH, BANK_DEPOSIT, and SAVINGS assets as liquid

**Steps:**
```powershell
cd D:\dev\repository\myproject\sasufamily\sasu-backend
mvn clean package -DskipTests
java -jar target/family-1.0.0.jar
```

Look for these log messages:
```
Running database migrations...
Adding 'is_liquid' column to assets table...
Successfully added 'is_liquid' column to assets table
Database migrations completed successfully
```

### Method 2: Manual SQL Script

If you prefer to run the migration manually:

```powershell
cd D:\dev\repository\myproject\sasufamily\sasu-backend
sqlite3 sasu_family.db < add_is_liquid_column.sql
```

Or directly:
```powershell
sqlite3 sasu_family.db "ALTER TABLE assets ADD COLUMN is_liquid BOOLEAN NOT NULL DEFAULT 0;"
```

### Method 3: Using a SQLite GUI Tool

Use tools like:
- DB Browser for SQLite
- DBeaver
- SQLiteStudio

Execute this SQL:
```sql
ALTER TABLE assets ADD COLUMN is_liquid BOOLEAN NOT NULL DEFAULT 0;
UPDATE assets SET is_liquid = 1 WHERE type IN ('CASH', 'BANK_DEPOSIT', 'SAVINGS');
```

## Verification

After migration, verify it worked:

```powershell
sqlite3 sasu_family.db "SELECT id, name, type, is_liquid FROM assets LIMIT 5;"
```

Or restart your application - if no errors appear, the migration succeeded!

## What is is_liquid?

The `is_liquid` flag marks assets that can be quickly converted to cash (within 3-6 months):
- ✅ CASH (cash in hand)
- ✅ BANK_DEPOSIT (bank savings)
- ✅ SAVINGS accounts
- ✅ Short-term Fixed Deposits
- ❌ Real estate (LAND, HOUSE)
- ❌ Long-term investments
- ❌ EPF/Retirement funds (locked until retirement)

This is used for calculating your **Liquidity & Emergency Fund Score** in the Wealth Health Dashboard.

## Troubleshooting

### Still getting the error?

1. **Stop the application** completely (kill any running Java processes)
2. **Check if column exists:**
   ```powershell
   sqlite3 sasu_family.db ".schema assets"
   ```
   You should see `is_liquid BOOLEAN NOT NULL DEFAULT 0` in the output

3. **Run migration manually:**
   ```powershell
   sqlite3 sasu_family.db "ALTER TABLE assets ADD COLUMN is_liquid BOOLEAN NOT NULL DEFAULT 0;"
   ```

4. **Restart application:**
   ```powershell
   cd D:\dev\repository\myproject\sasufamily\sasu-backend
   java -jar target/family-1.0.0.jar
   ```

### Column already exists error?

If you get "duplicate column name" error, the column already exists. Just restart the app.

### Can't find sqlite3 command?

Install SQLite:
1. Download from: https://www.sqlite.org/download.html
2. Extract to `C:\sqlite\`
3. Add to PATH or use full path: `C:\sqlite\sqlite3.exe`

Or just use the automatic migration method (restart the app).

## Files Changed

1. ✅ `Asset.java` - Already has the `isLiquid` field
2. ✅ `AssetService.java` - Already handles `isLiquid`
3. ✅ `DatabaseMigration.java` - NEW: Automatic migration component
4. ✅ `add_is_liquid_column.sql` - NEW: Manual migration script

