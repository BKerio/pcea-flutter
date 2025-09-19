import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import 'token_manager.dart';

/// Main API Service class for all backend communication
class ApiService {
  static final http.Client _client = http.Client();

  /// Get HTTP client with timeout configuration
  static http.Client get client => _client;

  /// Make authenticated HTTP request with automatic token handling
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.currentUrl}$endpoint');
      Map<String, String> requestHeaders = {...ApiConfig.defaultHeaders};

      if (requiresAuth) {
        final token = await TokenManager.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Authentication required: No valid token found');
        }
        requestHeaders.addAll(ApiConfig.authHeaders(token));
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: requestHeaders)
              .timeout(ApiConfig.requestTimeout);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.requestTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: requestHeaders)
              .timeout(ApiConfig.requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('HTTP error occurred. Please try again.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ========== AUTHENTICATION ENDPOINTS ==========

  /// Register a new user
  static Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final apiResponse = ApiResponse.fromResponse(response);
      
      // If registration is successful, save the token and user data
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data;
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }
        if (data['user'] != null) {
          try {
            final user = User.fromJson(data['user']);
            await TokenManager.saveUserId(user.id);
            await TokenManager.saveUserEmail(user.email);
          } catch (e) {
            print('Error parsing user data in registration: $e');
            print('User data: ${data['user']}');
            // Don't fail the entire registration, but log the error
          }
        }
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  static Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse.fromResponse(response);
      
      // If login is successful, save the token and user data
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data;
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }
        if (data['user'] != null) {
          try {
            final user = User.fromJson(data['user']);
            await TokenManager.saveUserId(user.id);
            await TokenManager.saveUserEmail(user.email);
          } catch (e) {
            print('Error parsing user data in login: $e');
            print('User data: ${data['user']}');
            // Don't fail the entire login, but log the error
          }
        }
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  /// Logout user
  static Future<ApiResponse> logout() async {
    try {
      final response = await _makeRequest(
        'POST',
        '/logout',
        requiresAuth: true,
      );

      final apiResponse = ApiResponse.fromResponse(response);
      
      // Clear stored authentication data regardless of API response
      await TokenManager.clearAll();

      return apiResponse;
    } catch (e) {
      // Clear stored data even if API call fails
      await TokenManager.clearAll();
      return ApiResponse.error('Logout failed: ${e.toString()}');
    }
  }

  // ========== USER PROFILE ENDPOINTS ==========

  /// Get basic user profile
  static Future<ApiResponse> getUser() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/user',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get user: ${e.toString()}');
    }
  }

  /// Get extended user profile
  static Future<ApiResponse> getUserProfile() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/profile',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get profile: ${e.toString()}');
    }
  }

  /// Update user profile
  static Future<ApiResponse> updateProfile(UserProfile profile) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/profile',
        body: profile.toJson(),
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update profile with custom data
  static Future<ApiResponse> updateProfileData(Map<String, dynamic> data) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/profile',
        body: data,
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update profile: ${e.toString()}');
    }
  }

  // ========== DEVICE TOKEN ENDPOINTS ==========

  /// Register device token for push notifications
  static Future<ApiResponse> registerDeviceToken({
    required String deviceToken,
    String deviceType = 'mobile',
    String? platform,
    String? appVersion,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/device-tokens',
        body: {
          'device_token': deviceToken,
          'device_type': deviceType,
          'platform': platform ?? Platform.operatingSystem,
          'app_version': appVersion,
        },
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to register device token: ${e.toString()}');
    }
  }

  /// Remove device token
  static Future<ApiResponse> removeDeviceToken(String deviceToken) async {
    try {
      final response = await _makeRequest(
        'DELETE',
        '/device-tokens/$deviceToken',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to remove device token: ${e.toString()}');
    }
  }

  // ========== APP CONFIGURATION ENDPOINTS ==========

  /// Get app configuration (public endpoint)
  static Future<ApiResponse> getAppConfig() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/config',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get app config: ${e.toString()}');
    }
  }

  /// Health check (public endpoint)
  static Future<ApiResponse> healthCheck() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/health',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Health check failed: ${e.toString()}');
    }
  }

  /// Get server time (public endpoint)
  static Future<ApiResponse> getServerTime() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/time',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get server time: ${e.toString()}');
    }
  }

  // ========== UTILITY METHODS ==========

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final response = await getUser();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user token (if refresh token is available)
  static Future<ApiResponse> refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        return ApiResponse.error('No refresh token available');
      }

      final response = await _makeRequest(
        'POST',
        '/refresh',
        body: {'refresh_token': refreshToken},
      );

      final apiResponse = ApiResponse.fromResponse(response);
      
      // If refresh is successful, save the new token
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data;
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }
        if (data['refresh_token'] != null) {
          await TokenManager.saveRefreshToken(data['refresh_token']);
        }
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse.error('Token refresh failed: ${e.toString()}');
    }
  }

  /// Test API connection
  static Future<bool> testConnection() async {
    try {
      final response = await healthCheck();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  // ========== MEMBER ENDPOINTS ==========

  /// Register a new member
  static Future<ApiResponse> registerMember({
    required String fullName,
    required DateTime dateOfBirth,
    String? nationalId,
    required String email,
    required String gender,
    required String maritalStatus,
    required String presbytery,
    required String parish,
    required String congregation,
    String? primarySchool,
    required bool isBaptized,
    required bool takesHolyCommunion,
    String? telephone,
    String? locationCounty,
    String? locationSubcounty,
    required String password,
    required String passwordConfirmation,
    List<Map<String, dynamic>>? dependencies,
  }) async {
    try {
      print('🚀 Starting member registration API call...');
      print('📧 Email: $email');
      print('🆔 National ID: $nationalId');
      print('👤 Full Name: $fullName');
      
      final requestBody = {
        'full_name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      
      print('📦 Request Body: $requestBody');
      
      final response = await _makeRequest(
        'POST',
        '/register',
        body: requestBody,
      );

      print('📡 Raw HTTP Response Status: ${response.statusCode}');
      print('📡 Raw HTTP Response Body: ${response.body}');

      final apiResponse = ApiResponse.fromResponse(response);
      print('📦 Parsed API Response: ${apiResponse.toString()}');
      
      // If registration is successful, save the token and user data
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data;
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
          print('💾 Token saved successfully');
        } else if (data['data'] != null && data['data']['access_token'] != null) {
          // Handle nested data structure
          await TokenManager.saveToken(data['data']['access_token']);
          print('💾 Token saved successfully (nested structure)');
        }
        
        // Try to save user data
        var userData = data['user'];
        if (userData == null && data['data'] != null) {
          userData = data['data']['user'];
        }
        
        if (userData != null) {
          try {
            // Extract only User-relevant fields from member registration response
            final userFields = {
              'id': userData['id'],
              'name': userData['full_name'],
              'email': userData['email'],
              'role': userData['role'] ?? 'member',
              'role_display': 'Member',
              'dashboard_route': '/member/dashboard',
              'created_at': userData['created_at'],
              'updated_at': userData['updated_at'],
            };
            
            final user = User.fromJson(userFields);
            await TokenManager.saveUserId(user.id);
            await TokenManager.saveUserEmail(user.email);
            print('👤 User data saved successfully');
          } catch (e) {
            print('❌ Error parsing member user data in registration: $e');
            print('👤 User data received: $userData');
          }
        }
      } else if (!apiResponse.isSuccess) {
        print('❌ Registration failed: ${apiResponse.message}');
        if (apiResponse.hasErrors) {
          print('❌ Validation errors: ${apiResponse.errorMessages.join(', ')}');
        }
      }

      return apiResponse;
    } catch (e) {
      print('💥 Member registration API exception: $e');
      return ApiResponse.error('Member registration failed: ${e.toString()}');
    }
  }

  /// Member login with National ID or E-Kanisa number
  static Future<ApiResponse> memberLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/member-login',
        body: {
          'identifier': identifier,
          'password': password,
        },
      );

      final apiResponse = ApiResponse.fromResponse(response);
      
      // If login is successful, save the token and user data
      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data;
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }
        if (data['user'] != null) {
          try {
            final user = User.fromJson(data['user']);
            await TokenManager.saveUserId(user.id);
            await TokenManager.saveUserEmail(user.email);
          } catch (e) {
            print('Error parsing member user data in login: $e');
            print('User data: ${data['user']}');
          }
        }
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse.error('Member login failed: ${e.toString()}');
    }
  }

  /// Get member profile
  static Future<ApiResponse> getMemberProfile() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/member/profile',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get member profile: ${e.toString()}');
    }
  }

  /// Update member profile
  static Future<ApiResponse> updateMemberProfile(Map<String, dynamic> data) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/member/profile',
        body: data,
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update member profile: ${e.toString()}');
    }
  }

  /// Get member dependents
  static Future<ApiResponse> getMemberDependents() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/member/dependents',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get dependents: ${e.toString()}');
    }
  }

  /// Add member dependent
  static Future<ApiResponse> addMemberDependent(Map<String, dynamic> dependent) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/member/dependents',
        body: dependent,
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to add dependent: ${e.toString()}');
    }
  }

  /// Update member dependent
  static Future<ApiResponse> updateMemberDependent(int dependentId, Map<String, dynamic> dependent) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/member/dependents/$dependentId',
        body: dependent,
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update dependent: ${e.toString()}');
    }
  }

  /// Delete member dependent
  static Future<ApiResponse> deleteMemberDependent(int dependentId) async {
    try {
      final response = await _makeRequest(
        'DELETE',
        '/member/dependents/$dependentId',
        requiresAuth: true,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to delete dependent: ${e.toString()}');
    }
  }

  /// Update member avatar
  static Future<ApiResponse> updateMemberAvatar(String imagePath) async {
    try {
      // This would require multipart/form-data handling
      // For now, we'll implement a basic version
      final response = await _makeRequest(
        'POST',
        '/member/profile/avatar',
        requiresAuth: true,
        body: {
          'avatar': imagePath, // This would need proper file upload implementation
        },
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update avatar: ${e.toString()}');
    }
  }

  // ========== LOCATION ENDPOINTS ==========

  /// Get all counties
  static Future<ApiResponse> getCounties() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/counties',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get counties: ${e.toString()}');
    }
  }

  /// Get constituencies for a county
  static Future<ApiResponse> getConstituencies(int countyId) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/constituencies?county_id=$countyId',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get constituencies: ${e.toString()}');
    }
  }

  /// Dispose resources
  static void dispose() {
    _client.close();
  }
}
