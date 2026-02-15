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
import '../models/income.dart';
import '../models/expense.dart';
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
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('cached_user');
  }

  // Cached user for quick access
  static User? _cachedUser;

  /// Check if user is logged in (has a valid token)
  static Future<bool> isLoggedIn() async {
    if (_token == null) {
      await init();
    }
    return _token != null && _token!.isNotEmpty;
  }

  /// Get current logged in user
  static Future<User?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('cached_user');
    if (userJson != null) {
      try {
        _cachedUser = User.fromJson(jsonDecode(userJson));
        return _cachedUser;
      } catch (e) {
        print('Failed to parse cached user: $e');
      }
    }
    return null;
  }

  /// Cache user after login
  static Future<void> _cacheUser(User user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', jsonEncode(user.toJson()));
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

  // Generic GET request
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('GET $endpoint failed: $e');
    }
    return null;
  }

  // Generic PUT request
  static Future<Map<String, dynamic>?> put(String endpoint, Map<String, dynamic> data) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('PUT $endpoint failed: $e');
    }
    return null;
  }

  // Login
  static Future<User> login(String username, String password) async {
    final url = ApiConfig.login;
    final headers = _getHeaders(includeAuth: false);
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConfig.timeout);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        if (user.token != null) {
          await saveToken(user.token!);
        }
        await _cacheUser(user);
        return user;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register
  static Future<void> register({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final url = ApiConfig.register;
    final headers = _getHeaders(includeAuth: false);
    final body = jsonEncode({
      'username': username,
      'password': password,
      'fullName': fullName,
      'role': role,
      'active': true,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return;
      } else {
        final errorMsg = response.body;
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
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

  // Get all incomes
  static Future<List<Income>> getIncomes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/incomes'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Income.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load incomes: ${response.body}');
    }
  }

  // Create income
  static Future<Income> createIncome(Income income) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/incomes'),
      headers: _getHeaders(),
      body: jsonEncode(income.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Income.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create income: ${response.body}');
    }
  }

  // Update income
  static Future<Income> updateIncome(int id, Income income) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/incomes/$id'),
      headers: _getHeaders(),
      body: jsonEncode(income.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Income.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update income: ${response.body}');
    }
  }

  // Delete income
  static Future<void> deleteIncome(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/incomes/$id'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete income: ${response.body}');
    }
  }

  // Get all expenses
  static Future<List<Expense>> getExpenses() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/expenses'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses: ${response.body}');
    }
  }

  // Create expense
  static Future<Expense> createExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/expenses'),
      headers: _getHeaders(),
      body: jsonEncode(expense.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create expense: ${response.body}');
    }
  }

  // Update expense
  static Future<Expense> updateExpense(int id, Expense expense) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/expenses/$id'),
      headers: _getHeaders(),
      body: jsonEncode(expense.toJson()),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update expense: ${response.body}');
    }
  }

  // Delete expense
  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/expenses/$id'),
      headers: _getHeaders(),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.body}');
    }
  }
}
