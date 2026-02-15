package com.sasu.family.service;

import com.sasu.family.model.AppConfig;
import com.sasu.family.repository.AppConfigRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppConfigService {

    private final AppConfigRepository appConfigRepository;

    // Config keys
    public static final String USD_TO_LKR_RATE = "USD_TO_LKR_RATE";

    // Default values
    public static final String DEFAULT_USD_TO_LKR = "298.50";

    public String getConfig(String key, String defaultValue) {
        return appConfigRepository.findByConfigKey(key)
                .map(AppConfig::getConfigValue)
                .orElse(defaultValue);
    }

    public void setConfig(String key, String value, String updatedBy) {
        Optional<AppConfig> existingConfig = appConfigRepository.findByConfigKey(key);

        AppConfig config;
        if (existingConfig.isPresent()) {
            config = existingConfig.get();
            config.setConfigValue(value);
        } else {
            config = AppConfig.builder()
                    .configKey(key)
                    .configValue(value)
                    .build();
        }

        config.setLastUpdated(LocalDateTime.now());
        config.setUpdatedBy(updatedBy);
        appConfigRepository.save(config);
    }

    // Convenience methods for exchange rate
    public BigDecimal getUsdToLkrRate() {
        String rate = getConfig(USD_TO_LKR_RATE, DEFAULT_USD_TO_LKR);
        try {
            return new BigDecimal(rate);
        } catch (NumberFormatException e) {
            return new BigDecimal(DEFAULT_USD_TO_LKR);
        }
    }

    public void setUsdToLkrRate(BigDecimal rate, String updatedBy) {
        setConfig(USD_TO_LKR_RATE, rate.toString(), updatedBy);
    }
}

