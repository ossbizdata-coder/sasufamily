package com.sasu.family.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Asset Model
 *
 * Represents a family-owned asset.
 *
 * Examples:
 * - Land
 * - House
 * - Fixed deposit
 * - Shares
 * - Savings
 * - EPF/Retirement funds
 *
 * Used for:
 * - Net worth calculation
 * - Asset summaries
 * - Future projections
 */
@Entity
@Table(name = "assets")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Asset {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AssetType type;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal currentValue;

    @Column(precision = 15, scale = 2)
    private BigDecimal purchaseValue;

    private Integer purchaseYear;

    @Column(length = 1000)
    private String description;

    @Column(precision = 5, scale = 2)
    private BigDecimal yearlyGrowthRate; // Annual appreciation percentage

    private LocalDate lastUpdated;

    @Column(nullable = false)
    private Boolean active = true;

    /**
     * Marks if this asset can be quickly converted to cash (within 3-6 months)
     * Examples: Cash, Savings, Fixed Deposits (short-term), Liquid Mutual Funds
     * Used for calculating Emergency Fund / Liquidity Score
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean isLiquid = false;

    /**
     * Marks if this asset is an investment (generates returns or appreciates)
     * Examples: Shares, Mutual Funds, Fixed Deposits, Land (investment), Rental Property
     * Used for calculating Investment Efficiency Score
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean isInvestment = false;

    public enum AssetType {
        LAND,
        HOUSE,
        VEHICLE,
        FIXED_DEPOSIT,
        SAVINGS,
        SHARES,
        EPF,
        RETIREMENT_FUND,
        GOLD,
        CASH,                    // Cash in hand
        BANK_DEPOSIT,            // Bank deposits/savings
        INSURANCE_INVESTMENT,    // Endowment/Savings insurance with investment returns
        OTHER
    }
}

