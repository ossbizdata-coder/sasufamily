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

    /**
     * Full purchase date for precise auto-growth calculations
     * Stored as String (YYYY-MM-DD) to avoid SQLite date parsing issues
     */
    @Column(name = "purchase_date")
    private String purchaseDate;

    @Column(length = 1000)
    private String description;

    @Column(name = "yearly_growth_rate", precision = 5, scale = 2)
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

    /**
     * If true, the current value is automatically calculated based on:
     * - Purchase value/date and yearly growth rate (compound interest)
     * This allows assets like EPF, Land to automatically show appreciated values
     */
    @Column(name = "auto_growth", nullable = false)
    @Builder.Default
    private Boolean autoGrowth = false;

    /**
     * Currency of the asset value (LKR or USD)
     * Used for multi-currency support
     */
    @Column(name = "currency", length = 3)
    @Builder.Default
    private String currency = "LKR";

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

