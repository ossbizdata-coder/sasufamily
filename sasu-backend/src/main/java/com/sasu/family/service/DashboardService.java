package com.sasu.family.service;

import com.sasu.family.dto.*;
import com.sasu.family.model.Asset;
import com.sasu.family.model.Expense;
import com.sasu.family.model.Income;
import com.sasu.family.model.Insurance;
import com.sasu.family.model.Liability;
import com.sasu.family.repository.AssetRepository;
import com.sasu.family.repository.ExpenseRepository;
import com.sasu.family.repository.IncomeRepository;
import com.sasu.family.repository.InsuranceRepository;
import com.sasu.family.repository.LiabilityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Dashboard Service
 *
 * Calculates wealth health score and provides dashboard summary.
 *
 * Scoring logic:
 * - High assets increase score
 * - High liabilities reduce score
 * - Good insurance coverage boosts score
 */
@Service
@RequiredArgsConstructor
public class DashboardService {

    private final AssetRepository assetRepository;
    private final LiabilityRepository liabilityRepository;
    private final InsuranceRepository insuranceRepository;
    private final IncomeRepository incomeRepository;
    private final ExpenseRepository expenseRepository;

    public DashboardSummaryDTO getDashboardSummary() {
        BigDecimal totalAssets = assetRepository.getTotalAssetValue();
        BigDecimal totalLiabilities = liabilityRepository.getTotalLiabilities();
        BigDecimal netWorth = totalAssets.subtract(totalLiabilities);
        BigDecimal totalCoverage = insuranceRepository.getTotalCoverage();
        BigDecimal monthlyBurden = liabilityRepository.getTotalMonthlyBurden();

        // Calculate monthly income and expenses
        BigDecimal monthlyIncome = calculateMonthlyIncome();
        BigDecimal monthlyExpenses = calculateMonthlyExpenses();

        // Calculate comprehensive score breakdown
        ScoreBreakdownDTO scoreBreakdown = calculateScoreBreakdown(
                totalAssets, totalLiabilities, netWorth, totalCoverage,
                monthlyIncome, monthlyExpenses, monthlyBurden
        );

        // Calculate overall wealth score from breakdown
        int wealthScore = scoreBreakdown.getNetWorthScore()
                + scoreBreakdown.getCashFlowScore()
                + scoreBreakdown.getDebtScore()
                + scoreBreakdown.getLiquidityScore()
                + scoreBreakdown.getInvestmentScore()
                + scoreBreakdown.getProtectionScore();

        String wealthLabel = getWealthLabel(wealthScore);
        String readiness = getFutureReadiness(wealthScore, totalCoverage);
        String message = getMotivationalMessage(wealthScore);

        List<AssetSummaryDTO> assetSummaries = getAssetSummaries();
        List<LiabilitySummaryDTO> liabilitySummaries = getLiabilitySummaries();
        long insuranceCount = insuranceRepository.findByActiveTrue().size();
        List<MonthlyBurdenDetailDTO> monthlyBurdenDetails = getMonthlyBurdenDetails();

        return DashboardSummaryDTO.builder()
                .totalAssets(totalAssets)
                .totalLiabilities(totalLiabilities)
                .netWorth(netWorth)
                .totalInsuranceCoverage(totalCoverage)
                .totalMonthlyBurden(monthlyBurden)
                .monthlyIncome(monthlyIncome)
                .monthlyExpenses(monthlyExpenses)
                .wealthHealthScore(wealthScore)
                .wealthHealthLabel(wealthLabel)
                .futureReadinessStatus(readiness)
                .scoreBreakdown(scoreBreakdown)
                .assetsByType(assetSummaries)
                .liabilitiesByType(liabilitySummaries)
                .totalInsurancePolicies((int) insuranceCount)
                .motivationalMessage(message)
                .monthlyBurdenDetails(monthlyBurdenDetails)
                .build();
    }

    private BigDecimal calculateMonthlyIncome() {
        List<Income> incomes = incomeRepository.findByActiveTrue();
        return incomes.stream()
                .map(Income::getMonthlyAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateMonthlyExpenses() {
        List<Expense> expenses = expenseRepository.findByActiveTrue();
        return expenses.stream()
                .map(Expense::getMonthlyAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    /**
     * Calculate comprehensive wealth health score using 6 pillars
     */
    private ScoreBreakdownDTO calculateScoreBreakdown(
            BigDecimal totalAssets,
            BigDecimal totalLiabilities,
            BigDecimal netWorth,
            BigDecimal totalCoverage,
            BigDecimal monthlyIncome,
            BigDecimal monthlyExpenses,
            BigDecimal monthlyBurden
    ) {
        // 1. NET WORTH GROWTH SCORE (25 points max)
        int netWorthScore = calculateNetWorthScore(netWorth, totalAssets);
        String netWorthStatus = getStatus(netWorthScore, 25);

        // 2. CASH FLOW HEALTH (20 points max)
        BigDecimal monthlySurplus = monthlyIncome.subtract(monthlyExpenses);
        BigDecimal savingsRate = monthlyIncome.compareTo(BigDecimal.ZERO) > 0
                ? monthlySurplus.divide(monthlyIncome, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;
        int cashFlowScore = calculateCashFlowScore(savingsRate);
        String cashFlowStatus = getStatus(cashFlowScore, 20);

        // 3. DEBT HEALTH (15 points max)
        BigDecimal debtToIncomeRatio = monthlyIncome.compareTo(BigDecimal.ZERO) > 0
                ? monthlyBurden.divide(monthlyIncome, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;
        BigDecimal debtRatio = totalAssets.compareTo(BigDecimal.ZERO) > 0
                ? totalLiabilities.divide(totalAssets, 4, RoundingMode.HALF_UP)
                : BigDecimal.ONE;
        int debtScore = calculateDebtScore(debtToIncomeRatio, debtRatio);
        String debtStatus = getDebtStatus(debtToIncomeRatio);

        // 4. LIQUIDITY (15 points max)
        BigDecimal liquidAssets = calculateLiquidAssets();
        BigDecimal emergencyFundMonths = monthlyExpenses.compareTo(BigDecimal.ZERO) > 0
                ? liquidAssets.divide(monthlyExpenses, 1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;
        int liquidityScore = calculateLiquidityScore(emergencyFundMonths);
        String liquidityStatus = getLiquidityStatus(emergencyFundMonths);

        // 5. INVESTMENT EFFICIENCY (15 points max)
        BigDecimal totalInvestments = calculateTotalInvestments();
        BigDecimal investmentRatio = totalAssets.compareTo(BigDecimal.ZERO) > 0
                ? totalInvestments.divide(totalAssets, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;
        int investmentScore = calculateInvestmentScore(investmentRatio);
        String investmentStatus = getStatus(investmentScore, 15);

        // 6. PROTECTION (10 points max)
        BigDecimal annualExpenses = monthlyExpenses.multiply(BigDecimal.valueOf(12));
        BigDecimal coverageRatio = annualExpenses.compareTo(BigDecimal.ZERO) > 0
                ? totalCoverage.divide(annualExpenses, 1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;
        boolean hasHealthIns = hasInsuranceType("HEALTH");
        boolean hasLifeIns = hasInsuranceType("LIFE");
        int protectionScore = calculateProtectionScore(coverageRatio, hasHealthIns, hasLifeIns);
        String protectionStatus = getProtectionStatus(protectionScore);

        return ScoreBreakdownDTO.builder()
                .netWorthScore(netWorthScore)
                .netWorthStatus(netWorthStatus)
                .netWorthValue(netWorth)
                .cashFlowScore(cashFlowScore)
                .cashFlowStatus(cashFlowStatus)
                .savingsRate(savingsRate)
                .monthlySurplus(monthlySurplus)
                .debtScore(debtScore)
                .debtStatus(debtStatus)
                .debtToIncomeRatio(debtToIncomeRatio)
                .debtRatio(debtRatio)
                .liquidityScore(liquidityScore)
                .liquidityStatus(liquidityStatus)
                .emergencyFundMonths(emergencyFundMonths)
                .liquidAssets(liquidAssets)
                .investmentScore(investmentScore)
                .investmentStatus(investmentStatus)
                .investmentRatio(investmentRatio)
                .totalInvestments(totalInvestments)
                .protectionScore(protectionScore)
                .protectionStatus(protectionStatus)
                .coverageRatio(coverageRatio)
                .hasHealthInsurance(hasHealthIns)
                .hasLifeInsurance(hasLifeIns)
                .build();
    }

    // 1. Net Worth Score (0-25)
    private int calculateNetWorthScore(BigDecimal netWorth, BigDecimal totalAssets) {
        if (netWorth.compareTo(BigDecimal.ZERO) <= 0) return 0;
        if (totalAssets.compareTo(BigDecimal.ZERO) == 0) return 0;

        // Positive net worth starts at 10 points
        int baseScore = 10;

        // Add points based on net worth to assets ratio
        BigDecimal netWorthRatio = netWorth.divide(totalAssets, 4, RoundingMode.HALF_UP);
        int ratioPoints = Math.min(10, netWorthRatio.multiply(BigDecimal.valueOf(20)).intValue());

        // Add points for absolute net worth (every 1M = 1 point, max 5)
        int absolutePoints = Math.min(5, netWorth.divide(BigDecimal.valueOf(1000000), 0, RoundingMode.DOWN).intValue());

        return Math.min(25, baseScore + ratioPoints + absolutePoints);
    }

    // 2. Cash Flow Score (0-20)
    private int calculateCashFlowScore(BigDecimal savingsRate) {
        if (savingsRate.compareTo(BigDecimal.ZERO) <= 0) return 0;
        if (savingsRate.compareTo(BigDecimal.valueOf(10)) < 0) return 5;  // < 10% weak
        if (savingsRate.compareTo(BigDecimal.valueOf(20)) < 0) return 12; // 10-20% average
        if (savingsRate.compareTo(BigDecimal.valueOf(30)) < 0) return 16; // 20-30% strong
        return 20; // 30%+ excellent
    }

    // 3. Debt Score (0-15)
    private int calculateDebtScore(BigDecimal debtToIncomeRatio, BigDecimal debtRatio) {
        int score = 15;

        // Penalty based on debt-to-income ratio
        if (debtToIncomeRatio.compareTo(BigDecimal.valueOf(30)) >= 0) {
            score -= 7; // High DTI
        } else if (debtToIncomeRatio.compareTo(BigDecimal.valueOf(20)) >= 0) {
            score -= 3; // Moderate DTI
        }

        // Penalty based on debt ratio
        if (debtRatio.compareTo(BigDecimal.valueOf(0.5)) >= 0) {
            score -= 5; // Debt > 50% of assets
        } else if (debtRatio.compareTo(BigDecimal.valueOf(0.3)) >= 0) {
            score -= 2; // Debt 30-50% of assets
        }

        return Math.max(0, score);
    }

    // 4. Liquidity Score (0-15)
    private int calculateLiquidityScore(BigDecimal emergencyMonths) {
        if (emergencyMonths.compareTo(BigDecimal.valueOf(12)) >= 0) return 15; // 12+ months excellent
        if (emergencyMonths.compareTo(BigDecimal.valueOf(6)) >= 0) return 12;  // 6-12 months strong
        if (emergencyMonths.compareTo(BigDecimal.valueOf(3)) >= 0) return 8;   // 3-6 months stable
        if (emergencyMonths.compareTo(BigDecimal.valueOf(1)) >= 0) return 4;   // 1-3 months weak
        return 0; // < 1 month critical
    }

    // 5. Investment Score (0-15)
    private int calculateInvestmentScore(BigDecimal investmentRatio) {
        if (investmentRatio.compareTo(BigDecimal.valueOf(50)) >= 0) return 15; // 50%+ excellent
        if (investmentRatio.compareTo(BigDecimal.valueOf(30)) >= 0) return 12; // 30-50% strong
        if (investmentRatio.compareTo(BigDecimal.valueOf(15)) >= 0) return 8;  // 15-30% moderate
        if (investmentRatio.compareTo(BigDecimal.valueOf(5)) >= 0) return 4;   // 5-15% weak
        return 0; // < 5% poor
    }

    // 6. Protection Score (0-10)
    private int calculateProtectionScore(BigDecimal coverageRatio, boolean hasHealth, boolean hasLife) {
        int score = 0;

        // Coverage ratio points (max 6)
        if (coverageRatio.compareTo(BigDecimal.valueOf(10)) >= 0) score += 6; // 10+ years covered
        else if (coverageRatio.compareTo(BigDecimal.valueOf(5)) >= 0) score += 4; // 5-10 years
        else if (coverageRatio.compareTo(BigDecimal.valueOf(2)) >= 0) score += 2; // 2-5 years
        else if (coverageRatio.compareTo(BigDecimal.valueOf(1)) >= 0) score += 1; // 1-2 years

        // Essential insurance points
        if (hasHealth) score += 2;
        if (hasLife) score += 2;

        return Math.min(10, score);
    }

    // Helper methods
    private BigDecimal calculateLiquidAssets() {
        List<Asset> assets = assetRepository.findByActiveTrue();
        // Sum all assets marked as liquid (cash, savings, short-term deposits, etc.)
        return assets.stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsLiquid()))
                .map(Asset::getCurrentValue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateTotalInvestments() {
        List<Asset> assets = assetRepository.findByActiveTrue();
        // Sum all assets marked as investments
        return assets.stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsInvestment()))
                .map(Asset::getCurrentValue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private boolean hasInsuranceType(String type) {
        List<Insurance> policies = insuranceRepository.findByActiveTrue();
        return policies.stream()
                .anyMatch(i -> i.getType().name().equals(type));
    }

    private String getStatus(int score, int maxScore) {
        double percentage = (score * 100.0) / maxScore;
        if (percentage >= 80) return "Excellent";
        if (percentage >= 60) return "Good";
        if (percentage >= 40) return "Fair";
        return "Poor";
    }

    private String getDebtStatus(BigDecimal dtiRatio) {
        if (dtiRatio.compareTo(BigDecimal.valueOf(20)) < 0) return "Excellent";
        if (dtiRatio.compareTo(BigDecimal.valueOf(30)) < 0) return "Good";
        if (dtiRatio.compareTo(BigDecimal.valueOf(40)) < 0) return "Fair";
        return "Critical";
    }

    private String getLiquidityStatus(BigDecimal months) {
        if (months.compareTo(BigDecimal.valueOf(6)) >= 0) return "Excellent";
        if (months.compareTo(BigDecimal.valueOf(3)) >= 0) return "Good";
        if (months.compareTo(BigDecimal.valueOf(1)) >= 0) return "Fair";
        return "Critical";
    }

    private String getProtectionStatus(int score) {
        if (score >= 8) return "Excellent";
        if (score >= 6) return "Good";
        if (score >= 4) return "Fair";
        return "Critical";
    }

    @Deprecated
    private int calculateWealthScore(BigDecimal assets, BigDecimal liabilities, BigDecimal coverage) {
        // Old simple calculation - kept for backward compatibility
        if (assets.compareTo(BigDecimal.ZERO) == 0) {
            return 0;
        }

        BigDecimal debtRatio = liabilities.divide(assets.add(BigDecimal.ONE), 2, RoundingMode.HALF_UP);
        BigDecimal coverageRatio = coverage.divide(assets.add(BigDecimal.ONE), 2, RoundingMode.HALF_UP);

        int baseScore = 50;
        int debtPenalty = debtRatio.multiply(BigDecimal.valueOf(30)).intValue();
        int coverageBonus = Math.min(30, coverageRatio.multiply(BigDecimal.valueOf(100)).intValue());
        int wealthBonus = Math.min(20, assets.divide(BigDecimal.valueOf(1000000), 0, RoundingMode.DOWN).intValue());

        int score = baseScore - debtPenalty + coverageBonus + wealthBonus;
        return Math.max(0, Math.min(100, score));
    }

    private String getWealthLabel(int score) {
        if (score >= 80) return "Excellent";
        if (score >= 60) return "Strong";
        if (score >= 40) return "Stable";
        if (score >= 20) return "Needs Attention";
        return "Critical";
    }

    private String getFutureReadiness(int score, BigDecimal coverage) {
        if (score >= 70 && coverage.compareTo(BigDecimal.valueOf(5000000)) > 0) {
            return "Fully Ready";
        } else if (score >= 50) {
            return "On Track";
        } else {
            return "Needs Planning";
        }
    }

    private List<AssetSummaryDTO> getAssetSummaries() {
        List<Asset> assets = assetRepository.findByActiveTrue();
        Map<Asset.AssetType, List<Asset>> grouped = assets.stream()
                .collect(Collectors.groupingBy(Asset::getType));

        return grouped.entrySet().stream()
                .map(entry -> {
                    BigDecimal total = entry.getValue().stream()
                            .map(Asset::getCurrentValue)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    return AssetSummaryDTO.builder()
                            .type(entry.getKey().name())
                            .count(entry.getValue().size())
                            .totalValue(total)
                            .build();
                })
                .collect(Collectors.toList());
    }

    private List<LiabilitySummaryDTO> getLiabilitySummaries() {
        List<Liability> liabilities = liabilityRepository.findByActiveTrue();
        Map<Liability.LiabilityType, List<Liability>> grouped = liabilities.stream()
                .collect(Collectors.groupingBy(Liability::getType));

        return grouped.entrySet().stream()
                .map(entry -> {
                    BigDecimal totalRemaining = entry.getValue().stream()
                            .map(Liability::getRemainingAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    BigDecimal monthlyBurden = entry.getValue().stream()
                            .map(l -> l.getMonthlyPayment() != null ? l.getMonthlyPayment() : BigDecimal.ZERO)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    return LiabilitySummaryDTO.builder()
                            .type(entry.getKey().name())
                            .count(entry.getValue().size())
                            .totalRemaining(totalRemaining)
                            .monthlyBurden(monthlyBurden)
                            .build();
                })
                .collect(Collectors.toList());
    }

    private List<MonthlyBurdenDetailDTO> getMonthlyBurdenDetails() {
        List<Liability> liabilities = liabilityRepository.findByActiveTrue();
        List<MonthlyBurdenDetailDTO> details = new ArrayList<>();
        for (Liability l : liabilities) {
            if (l.getMonthlyPayment() != null && l.getMonthlyPayment().signum() > 0) {
                details.add(MonthlyBurdenDetailDTO.builder()
                        .liabilityName(l.getName())
                        .type(l.getType().name())
                        .monthlyPayment(l.getMonthlyPayment())
                        .remainingAmount(l.getRemainingAmount())
                        .build());
            }
        }
        return details;
    }

    private String getMotivationalMessage(int score) {
        if (score >= 80) {
            return "Outstanding! Your family's financial future looks bright and secure.";
        } else if (score >= 60) {
            return "Great work! You're on the right path to financial wellness.";
        } else if (score >= 40) {
            return "Good foundation. A few improvements can strengthen your financial health.";
        } else if (score >= 20) {
            return "Building momentum. Small steps today create big wins tomorrow.";
        } else {
            return "Every journey starts with a single step. Let's build your financial strength together.";
        }
    }
}
