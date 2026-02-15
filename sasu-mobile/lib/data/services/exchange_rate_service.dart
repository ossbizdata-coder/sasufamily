import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Exchange Rate Service
///
/// Manages currency exchange rates.
/// - Fetches rate from backend (shared across all family members)
/// - Caches locally for offline access
/// - Admin can update the rate, all family members see the updated value

class ExchangeRateService {
  static const String _usdToLkrKey = 'usd_to_lkr_rate';
  static const String _lastUpdatedKey = 'exchange_rate_last_updated';

  // Default rate as fallback
  static const double defaultUsdToLkr = 298.50;

  static double? _cachedRate;
  static DateTime? _cachedLastUpdated;

  /// Fetch the USD to LKR rate from the backend
  static Future<double> fetchFromBackend() async {
    try {
      final response = await ApiService.get('/api/config/exchange-rate');
      if (response != null && response['usdToLkr'] != null) {
        final rate = (response['usdToLkr'] as num).toDouble();
        // Cache locally for offline use
        await _cacheRate(rate);
        return rate;
      }
    } catch (e) {
      print('Failed to fetch exchange rate from backend: $e');
    }
    // Fall back to cached rate
    return getUsdToLkrRate();
  }

  /// Cache the rate locally
  static Future<void> _cacheRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_usdToLkrKey, rate);
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    _cachedRate = rate;
    _cachedLastUpdated = DateTime.now();
  }

  /// Get the current USD to LKR exchange rate (from cache)
  static Future<double> getUsdToLkrRate() async {
    if (_cachedRate != null) {
      return _cachedRate!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedRate = prefs.getDouble(_usdToLkrKey) ?? defaultUsdToLkr;
    return _cachedRate!;
  }

  /// Get the rate synchronously (uses cached value or default)
  static double getUsdToLkrRateSync() {
    return _cachedRate ?? defaultUsdToLkr;
  }

  /// Update the USD to LKR exchange rate (Admin only - saves to backend)
  static Future<bool> setUsdToLkrRate(double rate) async {
    try {
      final response = await ApiService.put('/api/config/exchange-rate', {
        'usdToLkr': rate,
      });
      if (response != null) {
        await _cacheRate(rate);
        return true;
      }
    } catch (e) {
      print('Failed to update exchange rate: $e');
    }
    return false;
  }

  /// Get the last time the rate was updated
  static Future<DateTime?> getLastUpdated() async {
    if (_cachedLastUpdated != null) {
      return _cachedLastUpdated;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);
    if (lastUpdatedStr != null) {
      _cachedLastUpdated = DateTime.tryParse(lastUpdatedStr);
    }
    return _cachedLastUpdated;
  }

  /// Initialize the service (call at app startup)
  /// Fetches latest rate from backend
  static Future<void> init() async {
    // First load from local cache
    final prefs = await SharedPreferences.getInstance();
    _cachedRate = prefs.getDouble(_usdToLkrKey) ?? defaultUsdToLkr;
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);
    if (lastUpdatedStr != null) {
      _cachedLastUpdated = DateTime.tryParse(lastUpdatedStr);
    }

    // Then try to fetch from backend (non-blocking)
    fetchFromBackend().then((rate) {
      _cachedRate = rate;
    }).catchError((e) {
      print('Could not fetch exchange rate from backend: $e');
    });
  }

  /// Refresh rate from backend
  static Future<double> refresh() async {
    return await fetchFromBackend();
  }

  /// Convert USD to LKR
  static double convertUsdToLkr(double usdAmount) {
    return usdAmount * getUsdToLkrRateSync();
  }

  /// Convert LKR to USD
  static double convertLkrToUsd(double lkrAmount) {
    final rate = getUsdToLkrRateSync();
    if (rate == 0) return 0;
    return lkrAmount / rate;
  }
}

