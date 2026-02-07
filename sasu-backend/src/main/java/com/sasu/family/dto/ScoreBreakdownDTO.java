package com.sasu.family.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Score Breakdown DTO
 *
 * Detailed breakdown of the 6 pillars of wealth health:
 * 1. Net Worth Growth (25%)
 * 2. Cash Flow Health (20%)
 * 3. Debt Health (15%)
 * 4. Liquidity (15%)
 * 5. Investment Efficiency (15%)
 * 6. Protection & Risk Coverage (10%)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScoreBreakdownDTO {
    // 1. Net Worth Growth (25 points max)
    private Integer netWorthScore;          // 0-25
    private String netWorthStatus;          // Excellent, Good, Fair, Poor
    private BigDecimal netWorthValue;

    // 2. Cash Flow Health (20 points max)
    private Integer cashFlowScore;          // 0-20
    private String cashFlowStatus;          // Excellent, Good, Fair, Poor
    private BigDecimal savingsRate;         // Percentage
    private BigDecimal monthlySurplus;

    // 3. Debt Health (15 points max)
    private Integer debtScore;              // 0-15
    private String debtStatus;              // Excellent, Good, Fair, Critical
    private BigDecimal debtToIncomeRatio;   // Percentage
    private BigDecimal debtRatio;           // Debt/Assets ratio

    // 4. Liquidity (15 points max)
    private Integer liquidityScore;         // 0-15
    private String liquidityStatus;         // Excellent, Good, Fair, Critical
    private BigDecimal emergencyFundMonths; // Months of expenses covered
    private BigDecimal liquidAssets;

    // 5. Investment Efficiency (15 points max)
    private Integer investmentScore;        // 0-15
    private String investmentStatus;        // Excellent, Good, Fair, Poor
    private BigDecimal investmentRatio;     // Investments/Total Assets
    private BigDecimal totalInvestments;

    // 6. Protection (10 points max)
    private Integer protectionScore;        // 0-10
    private String protectionStatus;        // Excellent, Good, Fair, Critical
    private BigDecimal coverageRatio;       // Coverage/Annual Expenses
    private Boolean hasHealthInsurance;
    private Boolean hasLifeInsurance;
}

