package com.sasu.family.repository;

import com.sasu.family.model.Liability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface LiabilityRepository extends JpaRepository<Liability, Long> {
    List<Liability> findByActiveTrue();
    List<Liability> findByTypeAndActiveTrue(Liability.LiabilityType type);

    @Query("SELECT COALESCE(SUM(l.remainingAmount), 0) FROM Liability l WHERE l.active = true")
    BigDecimal getTotalLiabilities();

    @Query("SELECT COALESCE(SUM(l.monthlyPayment), 0) FROM Liability l WHERE l.active = true")
    BigDecimal getTotalMonthlyBurden();
}

