package com.sasu.family.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Liability Model
 *
 * Represents financial obligations.
 *
 * Examples:
 * - Bank loan
 * - Personal loan
 * - Credit balance
 * - Mortgage
 *
 * Used for:
 * - Net worth calculation
 * - Monthly burden analysis
 *
 * UI should never feel scary.
 * This model supports calm presentation of liabilities.
 */
@Entity
@Table(name = "liabilities")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Liability {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LiabilityType type;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal originalAmount;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal remainingAmount;

    @Column(precision = 15, scale = 2)
    private BigDecimal monthlyPayment;

    @Column(precision = 5, scale = 2)
    private BigDecimal interestRate;

    private LocalDate startDate;

    private LocalDate endDate;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private Boolean active = true;

    public enum LiabilityType {
        HOME_LOAN,
        VEHICLE_LOAN,
        PERSONAL_LOAN,
        EDUCATION_LOAN,
        CREDIT_CARD,
        OTHER
    }
}

