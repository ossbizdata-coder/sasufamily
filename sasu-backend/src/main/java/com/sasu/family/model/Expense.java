package com.sasu.family.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "expenses")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Expense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExpenseCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Frequency frequency;

    private LocalDate startDate;

    private String description;

    @Column(nullable = false)
    private Boolean active = true;

    @Column(nullable = false)
    private Boolean isNeed = true; // true for Needs, false for Wants

    public enum ExpenseCategory {
        FOOD,
        UTILITIES,
        TRANSPORTATION,
        EDUCATION,
        HEALTHCARE,
        ENTERTAINMENT,
        SHOPPING,
        HOUSING,
        INSURANCE,
        SAVINGS,
        OTHER
    }

    public enum Frequency {
        MONTHLY,
        QUARTERLY,
        YEARLY,
        ONE_TIME
    }

    public BigDecimal getMonthlyAmount() {
        if (frequency == Frequency.MONTHLY) {
            return amount;
        } else if (frequency == Frequency.QUARTERLY) {
            return amount.divide(BigDecimal.valueOf(3), 2, BigDecimal.ROUND_HALF_UP);
        } else if (frequency == Frequency.YEARLY) {
            return amount.divide(BigDecimal.valueOf(12), 2, BigDecimal.ROUND_HALF_UP);
        }
        return BigDecimal.ZERO;
    }
}

