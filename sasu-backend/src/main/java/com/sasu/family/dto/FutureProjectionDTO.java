package com.sasu.family.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Future Projection DTO
 *
 * Shows projected future benefits from:
 * - Insurance maturity
 * - EPF
 * - Asset appreciation
 *
 * Display year-wise projections.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FutureProjectionDTO {

    private List<YearlyProjection> projections;
    private BigDecimal totalFutureBenefits;
    private String summary;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class YearlyProjection {
        private Integer year;
        private Integer age;
        private BigDecimal insuranceMaturity;
        private BigDecimal assetValue;
        private BigDecimal totalValue;
        private String milestone;
    }
}

