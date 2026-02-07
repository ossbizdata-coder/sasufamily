package com.sasu.family.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MonthlyBurdenDetailDTO {
    private String liabilityName;
    private String type;
    private BigDecimal monthlyPayment;
    private BigDecimal remainingAmount;
}

