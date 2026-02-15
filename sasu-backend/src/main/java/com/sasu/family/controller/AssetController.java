package com.sasu.family.controller;

import com.sasu.family.model.Asset;
import com.sasu.family.service.AssetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Asset Controller
 *
 * ADMIN: Full CRUD access
 * FAMILY: Read-only access
 */
@RestController
@RequestMapping("/api/assets")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class AssetController {

    private final AssetService assetService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<List<Asset>> getAllAssets() {
        return ResponseEntity.ok(assetService.getAllAssets());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<Asset> getAssetById(@PathVariable Long id) {
        return ResponseEntity.ok(assetService.getAssetById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Asset> createAsset(@RequestBody Asset asset) {
        log.info("Creating asset: name={}, autoGrowth={}, purchaseDate={}, growthRate={}",
            asset.getName(), asset.getAutoGrowth(), asset.getPurchaseDate(), asset.getYearlyGrowthRate());
        return ResponseEntity.ok(assetService.createAsset(asset));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Asset> updateAsset(@PathVariable Long id, @RequestBody Asset asset) {
        log.info("Updating asset {}: name={}, autoGrowth={}, purchaseDate={}, growthRate={}",
            id, asset.getName(), asset.getAutoGrowth(), asset.getPurchaseDate(), asset.getYearlyGrowthRate());
        return ResponseEntity.ok(assetService.updateAsset(id, asset));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteAsset(@PathVariable Long id) {
        assetService.deleteAsset(id);
        return ResponseEntity.ok("Asset deleted successfully");
    }
}

