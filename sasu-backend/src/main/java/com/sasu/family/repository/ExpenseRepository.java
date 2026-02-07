package com.sasu.family.repository;

import com.sasu.family.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    List<Expense> findByActiveTrue();

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.active = true AND e.frequency = 'MONTHLY'")
    BigDecimal getTotalMonthlyExpenses();
}

