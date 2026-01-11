package com.sasu.family.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Dashboard Summary DTO
 *
 * Provides complete family financial health overview.
 *
 * Used by the main dashboard screen in mobile app.
 *
 * Shows:
 * - Net worth
 * - Wealth health score
 * - Future readiness
 * - Department-wise summaries
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryDTO {

    // Overall metrics
    private BigDecimal totalAssets;
    private BigDecimal totalLiabilities;
    private BigDecimal netWorth;

    // Protection & coverage
    private BigDecimal totalInsuranceCoverage;
    private BigDecimal totalMonthlyBurden;

    // Health indicators
    private Integer wealthHealthScore;      // 0-100
    private String wealthHealthLabel;       // Poor, Stable, Strong, Excellent
    private String futureReadinessStatus;   // Ready, Needs Attention, etc.

    // Breakdown
    private List<AssetSummaryDTO> assetsByType;
    private List<LiabilitySummaryDTO> liabilitiesByType;
    private Integer totalInsurancePolicies;

    // Motivational message
    private String motivationalMessage;
}

