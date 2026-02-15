package com.sasu.family.controller;

import com.sasu.family.service.AppConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Config Controller
 *
 * Manages app-wide configuration settings
 *
 * ADMIN: Can read and update config
 * FAMILY: Can only read config
 */
@RestController
@RequestMapping("/api/config")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ConfigController {

    private final AppConfigService appConfigService;

    /**
     * Get the current USD to LKR exchange rate
     */
    @GetMapping("/exchange-rate")
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<Map<String, Object>> getExchangeRate() {
        BigDecimal rate = appConfigService.getUsdToLkrRate();

        Map<String, Object> response = new HashMap<>();
        response.put("usdToLkr", rate);

        return ResponseEntity.ok(response);
    }

    /**
     * Update the USD to LKR exchange rate (Admin only)
     */
    @PutMapping("/exchange-rate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> updateExchangeRate(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {

        Object rateObj = request.get("usdToLkr");
        if (rateObj == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "usdToLkr is required"));
        }

        BigDecimal rate;
        try {
            rate = new BigDecimal(rateObj.toString());
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid rate format"));
        }

        if (rate.compareTo(BigDecimal.ZERO) <= 0) {
            return ResponseEntity.badRequest().body(Map.of("error", "Rate must be greater than 0"));
        }

        String username = authentication.getName();
        appConfigService.setUsdToLkrRate(rate, username);

        Map<String, Object> response = new HashMap<>();
        response.put("usdToLkr", rate);
        response.put("message", "Exchange rate updated successfully");

        return ResponseEntity.ok(response);
    }

    /**
     * Get all config values (for admin dashboard)
     */
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getAllConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("usdToLkr", appConfigService.getUsdToLkrRate());
        // Add more config values here as needed

        return ResponseEntity.ok(config);
    }
}

