/// API Service
///
/// Handles all HTTP communication with the backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/dashboard_summary.dart';
import '../models/asset.dart';
import '../models/insurance.dart';
import '../models/liability.dart';
import '../../core/constants/api_config.dart';

class ApiService {
  static String? _token;

  // Initialize token from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Login
  static Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      if (user.token != null) {
        await saveToken(user.token!);
      }
      return user;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Get Dashboard Summary
  static Future<DashboardSummary> getDashboardSummary() async {
    final response = await http.get(
      Uri.parse(ApiConfig.dashboardSummary),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }

  // Get all assets
  static Future<List<Asset>> getAssets() async {
    final response = await http.get(
      Uri.parse(ApiConfig.assets),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Asset.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assets: ${response.body}');
    }
  }

  // Create asset
  static Future<Asset> createAsset(Asset asset) async {
    final response = await http.post(
      Uri.parse(ApiConfig.assets),
      headers: _getHeaders(),
      body: jsonEncode(asset.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Asset.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create asset: ${response.body}');
    }
  }

  // Update asset
  static Future<Asset> updateAsset(int id, Asset asset) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.assets}/$id'),
      headers: _getHeaders(),
      body: jsonEncode(asset.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Asset.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update asset: ${response.body}');
    }
  }

  // Delete asset
  static Future<void> deleteAsset(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.assets}/$id'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete asset: ${response.body}');
    }
  }

  // Get all insurance
  static Future<List<Insurance>> getInsurance() async {
    final response = await http.get(
      Uri.parse(ApiConfig.insurance),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Insurance.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load insurance: ${response.body}');
    }
  }

  // Create insurance
  static Future<Insurance> createInsurance(Insurance insurance) async {
    final response = await http.post(
      Uri.parse(ApiConfig.insurance),
      headers: _getHeaders(),
      body: jsonEncode(insurance.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Insurance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create insurance: ${response.body}');
    }
  }

  // Update insurance
  static Future<Insurance> updateInsurance(int id, Insurance insurance) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.insurance}/$id'),
      headers: _getHeaders(),
      body: jsonEncode(insurance.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Insurance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update insurance: ${response.body}');
    }
  }

  // Delete insurance
  static Future<void> deleteInsurance(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.insurance}/$id'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete insurance: ${response.body}');
    }
  }

  // Get all liabilities
  static Future<List<Liability>> getLiabilities() async {
    final response = await http.get(
      Uri.parse(ApiConfig.liabilities),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Liability.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load liabilities: ${response.body}');
    }
  }

  // Create liability
  static Future<Liability> createLiability(Liability liability) async {
    final response = await http.post(
      Uri.parse(ApiConfig.liabilities),
      headers: _getHeaders(),
      body: jsonEncode(liability.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Liability.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create liability: ${response.body}');
    }
  }

  // Update liability
  static Future<Liability> updateLiability(int id, Liability liability) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.liabilities}/$id'),
      headers: _getHeaders(),
      body: jsonEncode(liability.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Liability.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update liability: ${response.body}');
    }
  }

  // Delete liability
  static Future<void> deleteLiability(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.liabilities}/$id'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete liability: ${response.body}');
    }
  }
}

