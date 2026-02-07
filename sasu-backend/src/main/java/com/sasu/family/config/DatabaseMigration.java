package com.sasu.family.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Database migration runner for schema updates
 * Executes on application startup to ensure database schema is up-to-date
 */
@Component
@Order(1) // Run early in the startup sequence
public class DatabaseMigration implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseMigration.class);
    private final JdbcTemplate jdbcTemplate;

    public DatabaseMigration(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        logger.info("Running database migrations...");

        // Migration: Add is_need column to expenses table
        addIsNeedColumnToExpenses();

        logger.info("Database migrations completed successfully");
    }

    /**
     * Add is_need column to expenses table
     * This column tracks whether an expense is a "Need" (essential) vs "Want" (discretionary)
     * Used for emergency fund calculation (needs-based expenses)
     */
    private void addIsNeedColumnToExpenses() {
        try {
            // Check if column already exists
            String checkColumnSql = "PRAGMA table_info(expenses)";
            var columns = jdbcTemplate.queryForList(checkColumnSql);

            boolean columnExists = columns.stream()
                .anyMatch(col -> "is_need".equals(col.get("name")));

            if (!columnExists) {
                logger.info("Adding is_need column to expenses table...");

                // Add the column with default value 1 (true - is a need)
                String alterTableSql = "ALTER TABLE expenses ADD COLUMN is_need INTEGER DEFAULT 1";
                jdbcTemplate.execute(alterTableSql);

                // Update existing records to mark as "Need" by default
                String updateSql = "UPDATE expenses SET is_need = 1 WHERE is_need IS NULL";
                int updated = jdbcTemplate.update(updateSql);

                logger.info("Successfully added is_need column to expenses table. Updated {} existing records.", updated);
            } else {
                logger.info("is_need column already exists in expenses table. Skipping migration.");
            }
        } catch (Exception e) {
            logger.error("Error adding is_need column to expenses table", e);
            throw new RuntimeException("Database migration failed: " + e.getMessage(), e);
        }
    }
}

