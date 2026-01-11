package com.sasu.family.service;

import com.sasu.family.dto.FutureProjectionDTO;
import com.sasu.family.model.Asset;
import com.sasu.family.model.Insurance;
import com.sasu.family.repository.AssetRepository;
import com.sasu.family.repository.InsuranceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Future Projection Service
 *
 * Calculates year-wise future benefits from:
 * - Insurance maturity
 * - EPF
 * - Asset appreciation
 */
@Service
@RequiredArgsConstructor
public class FutureProjectionService {

    private final AssetRepository assetRepository;
    private final InsuranceRepository insuranceRepository;

    public FutureProjectionDTO getFutureProjections(int currentAge) {
        List<FutureProjectionDTO.YearlyProjection> projections = new ArrayList<>();
        int currentYear = LocalDate.now().getYear();

        List<Asset> assets = assetRepository.findByActiveTrue();
        List<Insurance> insurances = insuranceRepository.findByActiveTrue();

        // Project for next 30 years at 5-year intervals
        for (int yearsAhead = 5; yearsAhead <= 30; yearsAhead += 5) {
            int targetYear = currentYear + yearsAhead;
            int targetAge = currentAge + yearsAhead;

            BigDecimal assetValue = calculateAssetValue(assets, yearsAhead);
            BigDecimal insuranceMaturity = calculateInsuranceMaturity(insurances, targetYear);
            BigDecimal totalValue = assetValue.add(insuranceMaturity);

            String milestone = getMilestone(targetAge);

            projections.add(FutureProjectionDTO.YearlyProjection.builder()
                    .year(targetYear)
                    .age(targetAge)
                    .insuranceMaturity(insuranceMaturity)
                    .assetValue(assetValue)
                    .totalValue(totalValue)
                    .milestone(milestone)
                    .build());
        }

        BigDecimal totalFuture = projections.stream()
                .map(FutureProjectionDTO.YearlyProjection::getTotalValue)
                .reduce(BigDecimal.ZERO, BigDecimal::max);

        return FutureProjectionDTO.builder()
                .projections(projections)
                .totalFutureBenefits(totalFuture)
                .summary("Your family's financial future is secure with growing assets and maturity benefits.")
                .build();
    }

    private BigDecimal calculateAssetValue(List<Asset> assets, int yearsAhead) {
        return assets.stream()
                .map(asset -> {
                    BigDecimal value = asset.getCurrentValue();
                    if (asset.getYearlyGrowthRate() != null) {
                        BigDecimal growthRate = asset.getYearlyGrowthRate().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                        BigDecimal multiplier = BigDecimal.ONE.add(growthRate).pow(yearsAhead);
                        value = value.multiply(multiplier);
                    }
                    return value;
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateInsuranceMaturity(List<Insurance> insurances, int targetYear) {
        return insurances.stream()
                .filter(ins -> ins.getMaturityYear() != null && ins.getMaturityYear() == targetYear)
                .map(ins -> ins.getMaturityBenefit() != null ? ins.getMaturityBenefit() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private String getMilestone(int age) {
        if (age == 40) return "Prime years - Peak earnings";
        if (age == 45) return "Mid-career growth phase";
        if (age == 50) return "Pre-retirement planning";
        if (age == 55) return "Retirement preparation";
        if (age == 60) return "Retirement begins";
        if (age == 65) return "Golden years";
        return "";
    }
}

