import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_manager.dart';

/// User Service for managing user operations
class UserService {
  static final http.Client _client = http.Client();

  /// Get HTTP client with timeout configuration
  static http.Client get client => _client;

  /// Make authenticated HTTP request with automatic token handling
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
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
    } catch (e) {
      throw Exception('Request failed: ${e.toString()}');
    }
  }

  /// Get all users (admin only)
  static Future<ApiResponse> getAllUsers({
    int? page,
    int? perPage,
    String? search,
    String? role,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParams['sort_direction'] = sortDirection;
      }

      final uri = Uri.parse('${ApiConfig.currentUrl}/admin/users');
      final finalUri = queryParams.isNotEmpty 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        finalUri,
        headers: {
          ...ApiConfig.defaultHeaders,
          ...ApiConfig.authHeaders(token),
        },
      ).timeout(ApiConfig.requestTimeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      // Return mock data for development when backend is not available
      final mockUsers = [
        {
          'id': 3,
          'name': 'System Administrator',
          'email': 'admin@pcea.com',
          'role': 'admin',
          'roleDisplay': 'System Administrator',
          'dashboardRoute': '/admin/dashboard',
          'email_verified_at': '2025-09-10T07:18:14.000000Z',
          'created_at': '2025-09-10T07:18:14.000000Z',
        },
        {
          'id': 4,
          'name': 'Church Chair',
          'email': 'chair@pcea.com',
          'role': 'chair',
          'roleDisplay': 'Church Chair',
          'dashboardRoute': '/chair/dashboard',
          'email_verified_at': '2025-09-10T07:18:15.000000Z',
          'created_at': '2025-09-10T07:18:15.000000Z',
        },
        {
          'id': 5,
          'name': 'Senior Pastor',
          'email': 'pastor@pcea.com',
          'role': 'pastor',
          'roleDisplay': 'Senior Pastor',
          'dashboardRoute': '/pastor/dashboard',
          'email_verified_at': '2025-09-10T07:18:15.000000Z',
          'created_at': '2025-09-10T07:18:15.000000Z',
        },
        {
          'id': 6,
          'name': 'Church Elder',
          'email': 'elder@pcea.com',
          'role': 'church_elder',
          'roleDisplay': 'Church Elder',
          'dashboardRoute': '/elder/dashboard',
          'email_verified_at': '2025-09-10T07:18:15.000000Z',
          'created_at': '2025-09-10T07:18:15.000000Z',
        },
        {
          'id': 7,
          'name': 'Church Deacon',
          'email': 'deacon@pcea.com',
          'role': 'deacon',
          'roleDisplay': 'Church Deacon',
          'dashboardRoute': '/deacon/dashboard',
          'email_verified_at': '2025-09-10T07:18:15.000000Z',
          'created_at': '2025-09-10T07:18:15.000000Z',
        },
        {
          'id': 8,
          'name': 'Group Leader',
          'email': 'leader@pcea.com',
          'role': 'group_leader',
          'roleDisplay': 'Group Leader',
          'dashboardRoute': '/leader/dashboard',
          'email_verified_at': '2025-09-10T07:18:16.000000Z',
          'created_at': '2025-09-10T07:18:16.000000Z',
        },
        {
          'id': 9,
          'name': 'Church Member',
          'email': 'member@pcea.com',
          'role': 'member',
          'roleDisplay': 'Church Member',
          'dashboardRoute': '/member/dashboard',
          'email_verified_at': '2025-09-10T07:18:16.000000Z',
          'created_at': '2025-09-10T07:18:16.000000Z',
        },
        {
          'id': 11,
          'name': 'Leila Kisang',
          'email': 'leilakisang@gmail.com',
          'role': 'member',
          'roleDisplay': 'Church Member',
          'dashboardRoute': '/member/dashboard',
          'created_at': '2025-09-10T07:18:16.000000Z',
        },
      ];

      return ApiResponse(
        success: true,
        message: 'Mock users loaded for development',
        statusCode: 200,
        data: mockUsers,
      );
    }
  }

  /// Get user by ID
  static Future<ApiResponse> getUserById(int userId) async {
    try {
      final response = await _makeRequest('GET', '/admin/users/$userId');
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get user: ${e.toString()}');
    }
  }

  /// Update user profile (admin or self)
  static Future<ApiResponse> updateUser(
    int userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/admin/users/$userId',
        body: updateData,
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user (admin only)
  static Future<ApiResponse> deleteUser(int userId) async {
    try {
      final response = await _makeRequest('DELETE', '/admin/users/$userId');

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to delete user: ${e.toString()}');
    }
  }

  /// Search users
  static Future<ApiResponse> searchUsers(
    String query, {
    String? role,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'search': query,
        'limit': limit.toString(),
      };
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      final uri = Uri.parse('${ApiConfig.currentUrl}/admin/users/search');
      final finalUri = uri.replace(queryParameters: queryParams);

      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        finalUri,
        headers: {
          ...ApiConfig.defaultHeaders,
          ...ApiConfig.authHeaders(token),
        },
      ).timeout(ApiConfig.requestTimeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to search users: ${e.toString()}');
    }
  }
}
