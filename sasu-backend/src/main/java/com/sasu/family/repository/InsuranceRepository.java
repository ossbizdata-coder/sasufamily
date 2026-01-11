package com.sasu.family.repository;

import com.sasu.family.model.Insurance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface InsuranceRepository extends JpaRepository<Insurance, Long> {
    List<Insurance> findByActiveTrue();
    List<Insurance> findByTypeAndActiveTrue(Insurance.InsuranceType type);

    @Query("SELECT COALESCE(SUM(i.coverageAmount), 0) FROM Insurance i WHERE i.active = true")
    BigDecimal getTotalCoverage();
}

