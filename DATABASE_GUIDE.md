# SQLite Database Best Practices for SaSu Family

## Configuration Applied

### 1. WAL Mode (Write-Ahead Logging)
```
journal_mode=WAL
```
- Allows concurrent reads while writing
- Better performance for web applications
- Database remains readable during writes
- Creates `.db-wal` and `.db-shm` files (these are normal)

### 2. Busy Timeout
```
busy_timeout=30000
```
- Waits 30 seconds if database is locked
- Prevents "database is locked" errors

### 3. Cache Size
```
cache_size=-20000
```
- Uses 20MB of memory for caching
- Negative value = KB, positive = pages
- Improves read performance

### 4. Foreign Keys
```
foreign_keys=ON
```
- Enforces referential integrity
- Prevents orphaned records

### 5. Connection Pool (HikariCP)
```
maximum-pool-size=1
minimum-idle=1
```
- SQLite only supports one writer at a time
- Single connection prevents lock contention

---

## Backup Strategy

### Daily Automated Backups
```bash
# Install backup script
sudo cp backup_sasu.sh /var/lib/sasu/
sudo chmod +x /var/lib/sasu/backup_sasu.sh

# Add to crontab (runs at 2 AM daily)
crontab -e
0 2 * * * /var/lib/sasu/backup_sasu.sh
```

### Manual Backup
```bash
# Quick backup
sqlite3 /var/lib/sasu/sasu.db ".backup /var/lib/sasu/backups/manual_backup.db"

# With WAL checkpoint first (recommended)
sqlite3 /var/lib/sasu/sasu.db "PRAGMA wal_checkpoint(TRUNCATE);"
sqlite3 /var/lib/sasu/sasu.db ".backup /var/lib/sasu/backups/manual_backup.db"
```

### Restore from Backup
```bash
# Stop the service
sudo systemctl stop sasu

# Restore
gunzip -c /var/lib/sasu/backups/sasu_backup_YYYYMMDD.db.gz > /var/lib/sasu/sasu.db

# Start the service
sudo systemctl start sasu
```

---

## Weekly Maintenance

```bash
# Install maintenance script
sudo cp maintain_sasu.sh /var/lib/sasu/
sudo chmod +x /var/lib/sasu/maintain_sasu.sh

# Add to crontab (runs at 3 AM every Sunday)
crontab -e
0 3 * * 0 /var/lib/sasu/maintain_sasu.sh
```

---

## Monitoring Commands

### Check Database Health
```bash
sqlite3 /var/lib/sasu/sasu.db "PRAGMA integrity_check;"
# Should return: ok
```

### Check WAL Status
```bash
sqlite3 /var/lib/sasu/sasu.db "PRAGMA wal_checkpoint;"
# Returns: busy, log, checkpointed
```

### Check Database Size
```bash
ls -lh /var/lib/sasu/sasu.db*
```

### View Table Statistics
```bash
sqlite3 /var/lib/sasu/sasu.db "
SELECT name, 
       (SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND tbl_name=m.name) as indexes
FROM sqlite_master m 
WHERE type='table' AND name NOT LIKE 'sqlite_%';
"
```

---

## Important Files

| File | Purpose |
|------|---------|
| `sasu.db` | Main database file |
| `sasu.db-wal` | Write-ahead log (WAL mode) |
| `sasu.db-shm` | Shared memory file (WAL mode) |

**Note:** When backing up, include all three files OR use `.backup` command which handles this automatically.

---

## Troubleshooting

### "Database is locked" error
```bash
# Check for processes using the database
fuser /var/lib/sasu/sasu.db

# Force checkpoint WAL
sqlite3 /var/lib/sasu/sasu.db "PRAGMA wal_checkpoint(TRUNCATE);"
```

### Database corruption (rare)
```bash
# Export and rebuild
sqlite3 /var/lib/sasu/sasu.db ".dump" > dump.sql
mv /var/lib/sasu/sasu.db /var/lib/sasu/sasu.db.corrupted
sqlite3 /var/lib/sasu/sasu.db < dump.sql
```

### Reclaim disk space after deleting data
```bash
sqlite3 /var/lib/sasu/sasu.db "VACUUM;"
```

