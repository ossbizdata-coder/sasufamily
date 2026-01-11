package com.sasu.family.repository;

import com.sasu.family.model.Asset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long> {
    List<Asset> findByActiveTrue();
    List<Asset> findByTypeAndActiveTrue(Asset.AssetType type);

    @Query("SELECT COALESCE(SUM(a.currentValue), 0) FROM Asset a WHERE a.active = true")
    BigDecimal getTotalAssetValue();
}

