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
public class LiabilitySummaryDTO {
    private String type;
    private Integer count;
    private BigDecimal totalRemaining;
    private BigDecimal monthlyBurden;
}

