class ApiConfig {
  // Base URLs for different environments
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // For development (local testing)
  static const String devUrl = 'http://127.0.0.1:8000/api';
  
  // For production - Update this with your actual production URL
  static const String prodUrl = 'https://your-domain.com/api';
  
  // Environment flag - Change to 'production' for production builds
  static const String environment = 'development';
  
  // Get the current API URL based on environment
  static String get currentUrl {
    switch (environment) {
      case 'production':
        return prodUrl;
      case 'development':
      default:
        return devUrl;
    }
  }

  // Default headers for all requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authentication token
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Connection timeout duration
  static const Duration connectionTimeout = Duration(seconds: 15);
}
