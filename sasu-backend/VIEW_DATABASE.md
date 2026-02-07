# How to View SQLite Database Locally

## Your Database Location
```
D:\dev\repository\myproject\sasufamily\sasu-backend\sasu_family.db
```

## Method 1: DB Browser for SQLite (Easiest - GUI)

### Download & Install
1. Go to: https://sqlitebrowser.org/dl/
2. Download "DB Browser for SQLite" for Windows
3. Install it (free software)

### Open Database
1. Launch DB Browser for SQLite
2. Click **"Open Database"** button
3. Navigate to: `D:\dev\repository\myproject\sasufamily\sasu-backend\sasu_family.db`
4. Click Open

### View Tables
- **Browse Data tab**: View/edit table contents
- **Database Structure tab**: See all tables and columns
- **Execute SQL tab**: Run custom SQL queries

### Check if is_liquid column exists:
1. Open the database
2. Go to "Database Structure" tab
3. Find "assets" table
4. Expand it to see all columns
5. Look for "is_liquid" column

---

## Method 2: Command Line (SQLite3)

### If you have sqlite3 installed:
```bash
cd D:\dev\repository\myproject\sasufamily\sasu-backend
sqlite3 sasu_family.db
```

### Useful Commands:
```sql
-- List all tables
.tables

-- Show structure of assets table
.schema assets

-- View all assets
SELECT * FROM assets;

-- Check if is_liquid column exists
PRAGMA table_info(assets);

-- Add is_liquid column manually if needed
ALTER TABLE assets ADD COLUMN is_liquid INTEGER NOT NULL DEFAULT 0;

-- Exit
.quit
```

---

## Method 3: VS Code Extension

### Install Extension:
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "SQLite"
4. Install "SQLite" by alexcvzz

### Use:
1. Right-click `sasu_family.db` in file explorer
2. Select "Open Database"
3. Click "SQLITE EXPLORER" in left sidebar
4. Expand database and tables

---

## Quick Check: Does is_liquid column exist?

### Using DB Browser:
1. Open database
2. Database Structure → assets table
3. Look for "is_liquid" column in the list

### Using Command Line:
```bash
cd D:\dev\repository\myproject\sasufamily\sasu-backend
sqlite3 sasu_family.db "PRAGMA table_info(assets);"
```

If you DON'T see "is_liquid", run this:
```bash
sqlite3 sasu_family.db "ALTER TABLE assets ADD COLUMN is_liquid INTEGER NOT NULL DEFAULT 0;"
```

---

## Current Tables in Your Database

Based on your application, you should have these tables:
- **assets** - All assets (properties, investments, cash, etc.)
- **liabilities** - All debts and liabilities
- **insurances** - Insurance policies
- **income_expense** - Monthly income and expense records
- **users** - User accounts
- **daily_cash** - Daily cash register (from shop management)
- **cash_transactions** - Transaction history
- **credits** - Credit records
- **expense_types** - Types of expenses
- **shops** - Shop details
- **attendance** - Staff attendance
- **audit_logs** - Activity logs

---

## Fix the is_liquid Column Issue

### Option 1: Restart Backend (Auto-update)
```bash
cd D:\dev\repository\myproject\sasufamily\sasu-backend
mvn spring-boot:run
```
Hibernate will automatically add the column because of:
```
spring.jpa.hibernate.ddl-auto=update
```

### Option 2: Manual SQL
```sql
ALTER TABLE assets ADD COLUMN is_liquid INTEGER NOT NULL DEFAULT 0;
```

### Verify:
```sql
SELECT id, name, type, is_liquid FROM assets LIMIT 5;
```

---

## Recommended: DB Browser for SQLite

**Why?**
- ✅ Visual interface (no commands to remember)
- ✅ See all data in tables
- ✅ Edit data directly
- ✅ Export to CSV/SQL
- ✅ No installation of command-line tools needed
- ✅ Free and open source

**Download:** https://sqlitebrowser.org/dl/

