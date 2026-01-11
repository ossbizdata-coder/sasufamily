package com.sasu.family;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * SaSu Family Wealth & Future Readiness Dashboard
 *
 * Main Application Entry Point
 *
 * Purpose:
 * - Family financial overview platform
 * - Admin (Father) manages data
 * - Family (Wife, Daughter) views data
 * - Calm, motivating, safe design
 */
@SpringBootApplication
public class SaSuApplication {

    public static void main(String[] args) {
        SpringApplication.run(SaSuApplication.class, args);
        System.out.println("🏡 SaSu Family Wealth Dashboard - Backend Running");
    }
}

