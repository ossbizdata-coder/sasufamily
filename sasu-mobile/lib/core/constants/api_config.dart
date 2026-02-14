/// API Configuration
///
/// Backend endpoint configuration

class ApiConfig {
  // Production backend URL via nginx proxy
  // nginx routes /sasu/ to port 8082/api/
  static const String baseUrl = 'http://74.208.132.78/sasu';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Dashboard
  static const String dashboardSummary = '$baseUrl/dashboard/summary';

  // Assets
  static const String assets = '$baseUrl/assets';

  // Insurance
  static const String insurance = '$baseUrl/insurance';

  // Liabilities
  static const String liabilities = '$baseUrl/liabilities';

  // Future Projections
  static const String futureProjections = '$baseUrl/future/projections';

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}

