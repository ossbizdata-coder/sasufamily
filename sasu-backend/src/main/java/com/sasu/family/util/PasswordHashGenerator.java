package com.sasu.family.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * Password Hash Generator
 *
 * Simple utility to generate BCrypt password hashes.
 * Run this to get the correct hash for updating passwords manually.
 */
public class PasswordHashGenerator {

    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        System.out.println("=== Password Hash Generator ===\n");

        // Generate hashes for default passwords
        String admin123 = encoder.encode("admin123");
        String wife123 = encoder.encode("wife123");
        String daughter123 = encoder.encode("daughter123");

        System.out.println("admin123 hash:");
        System.out.println(admin123);
        System.out.println();

        System.out.println("wife123 hash:");
        System.out.println(wife123);
        System.out.println();

        System.out.println("daughter123 hash:");
        System.out.println(daughter123);
        System.out.println();

        System.out.println("=== SQL Update Statements ===\n");
        System.out.println("UPDATE users SET password = '" + admin123 + "' WHERE username = 'admin';");
        System.out.println("UPDATE users SET password = '" + wife123 + "' WHERE username = 'wife';");
        System.out.println("UPDATE users SET password = '" + daughter123 + "' WHERE username = 'daughter';");
    }
}

