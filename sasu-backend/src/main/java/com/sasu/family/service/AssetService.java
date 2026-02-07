package com.sasu.family.service;

import com.sasu.family.model.Asset;
import com.sasu.family.repository.AssetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AssetService {

    private final AssetRepository assetRepository;

    public List<Asset> getAllAssets() {
        return assetRepository.findByActiveTrue();
    }

    public Asset getAssetById(Long id) {
        return assetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Asset not found"));
    }

    public Asset createAsset(Asset asset) {
        asset.setLastUpdated(LocalDate.now());
        asset.setActive(true);
        return assetRepository.save(asset);
    }

    public Asset updateAsset(Long id, Asset assetDetails) {
        Asset asset = getAssetById(id);

        asset.setName(assetDetails.getName());
        asset.setType(assetDetails.getType());
        asset.setCurrentValue(assetDetails.getCurrentValue());
        asset.setPurchaseValue(assetDetails.getPurchaseValue());
        asset.setPurchaseYear(assetDetails.getPurchaseYear());
        asset.setDescription(assetDetails.getDescription());
        asset.setYearlyGrowthRate(assetDetails.getYearlyGrowthRate());
        asset.setIsLiquid(assetDetails.getIsLiquid());
        asset.setLastUpdated(LocalDate.now());

        return assetRepository.save(asset);
    }

    public void deleteAsset(Long id) {
        Asset asset = getAssetById(id);
        asset.setActive(false);
        assetRepository.save(asset);
    }
}

