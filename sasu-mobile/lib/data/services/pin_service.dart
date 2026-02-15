import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// PIN Service
///
/// Handles PIN storage and verification for app lock functionality.
/// PIN is stored as a hash for security.
class PinService {
  static const String _pinKey = 'app_pin_hash';
  static const String _pinEnabledKey = 'app_pin_enabled';
  static const String _biometricEnabledKey = 'app_biometric_enabled';

  /// Hash the PIN using SHA-256
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if PIN is set up
  static Future<bool> isPinSetUp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey) && (prefs.getBool(_pinEnabledKey) ?? false);
  }

  /// Set up a new PIN
  static Future<bool> setPin(String pin) async {
    if (pin.length != 4) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final hashedPin = _hashPin(pin);
    await prefs.setString(_pinKey, hashedPin);
    await prefs.setBool(_pinEnabledKey, true);
    return true;
  }

  /// Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinKey);

    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  /// Change PIN (requires old PIN verification)
  static Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;

    return await setPin(newPin);
  }

  /// Disable PIN lock
  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, false);
  }

  /// Enable PIN lock (PIN must already be set)
  static Future<bool> enablePin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_pinKey)) return false;

    await prefs.setBool(_pinEnabledKey, true);
    return true;
  }

  /// Clear all PIN data (for logout)
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_pinEnabledKey);
    await prefs.remove(_biometricEnabledKey);
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Set biometric enabled state
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
}

