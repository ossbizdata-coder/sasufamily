package com.sasu.family.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Insurance Model
 *
 * Represents an insurance policy that provides protection or future benefit.
 *
 * Examples:
 * - Life insurance
 * - Medical insurance
 * - Education plan
 * - Vehicle insurance
 *
 * Key focus:
 * - Coverage amount
 * - Maturity year
 * - Beneficiaries
 *
 * Used for:
 * - Family protection score
 * - Future benefit projections
 */
@Entity
@Table(name = "insurance")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Insurance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String policyName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InsuranceType type;

    @Column(nullable = false)
    private String provider;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal coverageAmount;

    @Column(precision = 15, scale = 2)
    private BigDecimal premiumAmount;

    @Enumerated(EnumType.STRING)
    private PremiumFrequency premiumFrequency;

    private LocalDate startDate;

    private Integer maturityYear;

    @Column(precision = 15, scale = 2)
    private BigDecimal maturityBenefit;

    @Column(nullable = false)
    private String beneficiary;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;

    public enum InsuranceType {
        LIFE,
        MEDICAL,
        EDUCATION,
        VEHICLE,
        HOME,
        OTHER
    }

    public enum PremiumFrequency {
        MONTHLY,
        QUARTERLY,
        HALF_YEARLY,
        YEARLY
    }
}

