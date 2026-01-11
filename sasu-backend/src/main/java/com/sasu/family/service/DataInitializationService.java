package com.sasu.family.service;

import com.sasu.family.model.Asset;
import com.sasu.family.model.Insurance;
import com.sasu.family.model.Liability;
import com.sasu.family.model.User;
import com.sasu.family.repository.AssetRepository;
import com.sasu.family.repository.InsuranceRepository;
import com.sasu.family.repository.LiabilityRepository;
import com.sasu.family.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Data Initialization Service
 *
 * Creates initial demo data for the application.
 *
 * Default users:
 * - admin/admin123 (ADMIN role)
 * - wife/wife123 (FAMILY role)
 * - daughter/daughter123 (FAMILY role)
 */
@Component
@RequiredArgsConstructor
public class DataInitializationService implements CommandLineRunner {

    private final UserRepository userRepository;
    private final AssetRepository assetRepository;
    private final InsuranceRepository insuranceRepository;
    private final LiabilityRepository liabilityRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.count() == 0) {
            initializeUsers();
            initializeAssets();
            initializeInsurance();
            initializeLiabilities();
            System.out.println("✅ Sample data initialized successfully!");
        }
    }

    private void initializeUsers() {
        // Admin user (Father)
        User admin = User.builder()
                .username("admin")
                .password(passwordEncoder.encode("admin123"))
                .fullName("Father (Admin)")
                .role(User.UserRole.ADMIN)
                .active(true)
                .build();
        userRepository.save(admin);

        // Wife
        User wife = User.builder()
                .username("wife")
                .password(passwordEncoder.encode("wife123"))
                .fullName("Mother")
                .role(User.UserRole.FAMILY)
                .active(true)
                .build();
        userRepository.save(wife);

        // Daughter
        User daughter = User.builder()
                .username("daughter")
                .password(passwordEncoder.encode("daughter123"))
                .fullName("Daughter")
                .role(User.UserRole.FAMILY)
                .active(true)
                .build();
        userRepository.save(daughter);

        System.out.println("👥 Users created: admin, wife, daughter");
    }

    private void initializeAssets() {
        // Land
        Asset land = Asset.builder()
                .name("Ancestral Land")
                .type(Asset.AssetType.LAND)
                .currentValue(new BigDecimal("15000000"))
                .purchaseValue(new BigDecimal("5000000"))
                .purchaseYear(2010)
                .yearlyGrowthRate(new BigDecimal("8.0"))
                .description("Family land in hometown")
                .lastUpdated(LocalDate.now())
                .active(true)
                .build();
        assetRepository.save(land);

        // House
        Asset house = Asset.builder()
                .name("Family Home")
                .type(Asset.AssetType.HOUSE)
                .currentValue(new BigDecimal("25000000"))
                .purchaseValue(new BigDecimal("18000000"))
                .purchaseYear(2015)
                .yearlyGrowthRate(new BigDecimal("5.0"))
                .description("Current residence")
                .lastUpdated(LocalDate.now())
                .active(true)
                .build();
        assetRepository.save(house);

        // EPF
        Asset epf = Asset.builder()
                .name("EPF Savings")
                .type(Asset.AssetType.EPF)
                .currentValue(new BigDecimal("8000000"))
                .yearlyGrowthRate(new BigDecimal("10.0"))
                .description("Retirement fund")
                .lastUpdated(LocalDate.now())
                .active(true)
                .build();
        assetRepository.save(epf);

        // Fixed Deposit
        Asset fd = Asset.builder()
                .name("Bank Fixed Deposit")
                .type(Asset.AssetType.FIXED_DEPOSIT)
                .currentValue(new BigDecimal("3000000"))
                .yearlyGrowthRate(new BigDecimal("6.5"))
                .description("Emergency fund")
                .lastUpdated(LocalDate.now())
                .active(true)
                .build();
        assetRepository.save(fd);

        // Savings
        Asset savings = Asset.builder()
                .name("Savings Account")
                .type(Asset.AssetType.SAVINGS)
                .currentValue(new BigDecimal("1500000"))
                .yearlyGrowthRate(new BigDecimal("2.0"))
                .description("Family savings")
                .lastUpdated(LocalDate.now())
                .active(true)
                .build();
        assetRepository.save(savings);

        System.out.println("🏠 Assets created: 5 items");
    }

    private void initializeInsurance() {
        // Life Insurance
        Insurance life = Insurance.builder()
                .policyName("Family Life Protection Plan")
                .type(Insurance.InsuranceType.LIFE)
                .provider("Insurance Company A")
                .coverageAmount(new BigDecimal("10000000"))
                .premiumAmount(new BigDecimal("50000"))
                .premiumFrequency(Insurance.PremiumFrequency.MONTHLY)
                .startDate(LocalDate.of(2020, 1, 1))
                .maturityYear(2045)
                .maturityBenefit(new BigDecimal("15000000"))
                .beneficiary("Wife and Daughter")
                .description("Comprehensive life coverage")
                .active(true)
                .build();
        insuranceRepository.save(life);

        // Medical Insurance
        Insurance medical = Insurance.builder()
                .policyName("Family Health Shield")
                .type(Insurance.InsuranceType.MEDICAL)
                .provider("Insurance Company B")
                .coverageAmount(new BigDecimal("5000000"))
                .premiumAmount(new BigDecimal("30000"))
                .premiumFrequency(Insurance.PremiumFrequency.YEARLY)
                .startDate(LocalDate.of(2021, 6, 1))
                .beneficiary("Entire Family")
                .description("Complete health coverage")
                .active(true)
                .build();
        insuranceRepository.save(medical);

        // Education Plan
        Insurance education = Insurance.builder()
                .policyName("Daughter Education Plan")
                .type(Insurance.InsuranceType.EDUCATION)
                .provider("Insurance Company C")
                .coverageAmount(new BigDecimal("3000000"))
                .premiumAmount(new BigDecimal("25000"))
                .premiumFrequency(Insurance.PremiumFrequency.MONTHLY)
                .startDate(LocalDate.of(2022, 1, 1))
                .maturityYear(2035)
                .maturityBenefit(new BigDecimal("5000000"))
                .beneficiary("Daughter")
                .description("Higher education fund")
                .active(true)
                .build();
        insuranceRepository.save(education);

        System.out.println("🛡️ Insurance policies created: 3 items");
    }

    private void initializeLiabilities() {
        // Home Loan
        Liability homeLoan = Liability.builder()
                .name("Home Loan")
                .type(Liability.LiabilityType.HOME_LOAN)
                .originalAmount(new BigDecimal("10000000"))
                .remainingAmount(new BigDecimal("6000000"))
                .monthlyPayment(new BigDecimal("80000"))
                .interestRate(new BigDecimal("7.5"))
                .startDate(LocalDate.of(2015, 3, 1))
                .endDate(LocalDate.of(2030, 3, 1))
                .description("Housing loan for family home")
                .active(true)
                .build();
        liabilityRepository.save(homeLoan);

        // Vehicle Loan
        Liability vehicleLoan = Liability.builder()
                .name("Car Loan")
                .type(Liability.LiabilityType.VEHICLE_LOAN)
                .originalAmount(new BigDecimal("3000000"))
                .remainingAmount(new BigDecimal("1200000"))
                .monthlyPayment(new BigDecimal("45000"))
                .interestRate(new BigDecimal("9.0"))
                .startDate(LocalDate.of(2021, 6, 1))
                .endDate(LocalDate.of(2026, 6, 1))
                .description("Family vehicle loan")
                .active(true)
                .build();
        liabilityRepository.save(vehicleLoan);

        System.out.println("💳 Liabilities created: 2 items");
    }
}

