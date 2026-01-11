package com.sasu.family.service;

import com.sasu.family.dto.*;
import com.sasu.family.model.Asset;
import com.sasu.family.model.Insurance;
import com.sasu.family.model.Liability;
import com.sasu.family.repository.AssetRepository;
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

    public DashboardSummaryDTO getDashboardSummary() {
        BigDecimal totalAssets = assetRepository.getTotalAssetValue();
        BigDecimal totalLiabilities = liabilityRepository.getTotalLiabilities();
        BigDecimal netWorth = totalAssets.subtract(totalLiabilities);
        BigDecimal totalCoverage = insuranceRepository.getTotalCoverage();
        BigDecimal monthlyBurden = liabilityRepository.getTotalMonthlyBurden();

        int wealthScore = calculateWealthScore(totalAssets, totalLiabilities, totalCoverage);
        String wealthLabel = getWealthLabel(wealthScore);
        String readiness = getFutureReadiness(wealthScore, totalCoverage);
        String message = getMotivationalMessage(wealthScore);

        List<AssetSummaryDTO> assetSummaries = getAssetSummaries();
        List<LiabilitySummaryDTO> liabilitySummaries = getLiabilitySummaries();
        long insuranceCount = insuranceRepository.findByActiveTrue().size();

        return DashboardSummaryDTO.builder()
                .totalAssets(totalAssets)
                .totalLiabilities(totalLiabilities)
                .netWorth(netWorth)
                .totalInsuranceCoverage(totalCoverage)
                .totalMonthlyBurden(monthlyBurden)
                .wealthHealthScore(wealthScore)
                .wealthHealthLabel(wealthLabel)
                .futureReadinessStatus(readiness)
                .assetsByType(assetSummaries)
                .liabilitiesByType(liabilitySummaries)
                .totalInsurancePolicies((int) insuranceCount)
                .motivationalMessage(message)
                .build();
    }

    private int calculateWealthScore(BigDecimal assets, BigDecimal liabilities, BigDecimal coverage) {
        if (assets.compareTo(BigDecimal.ZERO) == 0) {
            return 0;
        }

        // Calculate debt ratio (lower is better)
        BigDecimal debtRatio = liabilities.divide(assets.add(BigDecimal.ONE), 2, RoundingMode.HALF_UP);

        // Calculate coverage ratio (higher is better)
        BigDecimal coverageRatio = coverage.divide(assets.add(BigDecimal.ONE), 2, RoundingMode.HALF_UP);

        // Base score from net worth
        int baseScore = 50;

        // Adjust for debt (max -30 points)
        int debtPenalty = debtRatio.multiply(BigDecimal.valueOf(30)).intValue();

        // Adjust for coverage (max +30 points)
        int coverageBonus = Math.min(30, coverageRatio.multiply(BigDecimal.valueOf(100)).intValue());

        // Adjust for absolute wealth (max +20 points)
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

    private String getMotivationalMessage(int score) {
        if (score >= 80) {
            return "Your family is financially strong and well-prepared for the future! ❤️";
        } else if (score >= 60) {
            return "Great work! Your family's financial foundation is solid. 👍";
        } else if (score >= 40) {
            return "You're building a stable future for your family. Keep going! 💪";
        } else {
            return "Every step towards financial planning matters. You're on the right path! 🌱";
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
}

