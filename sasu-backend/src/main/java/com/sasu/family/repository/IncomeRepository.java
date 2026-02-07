package com.sasu.family.repository;

import com.sasu.family.model.Income;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface IncomeRepository extends JpaRepository<Income, Long> {

    List<Income> findByActiveTrue();

    @Query("SELECT COALESCE(SUM(i.amount), 0) FROM Income i WHERE i.active = true AND i.frequency = 'MONTHLY'")
    BigDecimal getTotalMonthlyIncome();
}

