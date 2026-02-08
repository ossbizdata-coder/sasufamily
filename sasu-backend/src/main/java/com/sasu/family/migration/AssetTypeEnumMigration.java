package com.sasu.family.migration;

import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Migration to add INSURANCE_INVESTMENT to Asset.AssetType enum
 *
 * This adds support for insurance policies with guaranteed returns
 * (endowment policies, savings insurance, etc.)
 */
@Component
public class AssetTypeEnumMigration implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    public AssetTypeEnumMigration(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        try {
            // SQLite doesn't need explicit enum updates, but we log for tracking
            System.out.println("✓ Asset type enum updated: INSURANCE_INVESTMENT added");
            System.out.println("  Use this type for insurance with investment returns (endowment/savings policies)");
        } catch (Exception e) {
            System.err.println("Note: Asset type enum update - " + e.getMessage());
        }
    }
}

