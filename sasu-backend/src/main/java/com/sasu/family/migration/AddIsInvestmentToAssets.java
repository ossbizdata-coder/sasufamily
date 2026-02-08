package com.sasu.family.migration;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Migration: Add isInvestment column to assets table
 *
 * Adds a new boolean column to track investment assets for calculating
 * Investment Efficiency Score in the Wealth Health Scorecard.
 */
@Component
@Order(7)
public class AddIsInvestmentToAssets implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            // Check if column already exists
            String checkColumnSql =
                "SELECT COUNT(*) FROM pragma_table_info('assets') WHERE name = 'is_investment'";

            Integer count = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);

            if (count != null && count == 0) {
                // Add is_investment column with default value false
                String alterTableSql =
                    "ALTER TABLE assets ADD COLUMN is_investment INTEGER NOT NULL DEFAULT 0";
                jdbcTemplate.execute(alterTableSql);

                System.out.println("✓ Migration: Added is_investment column to assets table");

                // Optionally: Auto-mark certain asset types as investments
                // (You can customize this logic based on your needs)
                String updateSql =
                    "UPDATE assets SET is_investment = 1 WHERE type IN ('SHARES', 'FIXED_DEPOSIT', 'RETIREMENT_FUND', 'EPF')";
                int updated = jdbcTemplate.update(updateSql);

                System.out.println("✓ Migration: Auto-marked " + updated + " assets as investments");
            } else {
                System.out.println("⊘ Migration: is_investment column already exists in assets table");
            }
        } catch (Exception e) {
            System.err.println("✗ Migration failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

