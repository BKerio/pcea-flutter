import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_manager.dart';

/// Role Management Service for admin operations
class RoleManagementService {
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
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // ========== ROLE MANAGEMENT ENDPOINTS ==========

  /// Get all available roles with descriptions
  static Future<ApiResponse> getAvailableRoles() async {
    try {
      final response = await _makeRequest('GET', '/admin/roles');
      return ApiResponse.fromResponse(response);
    } catch (e) {
      // Return mock data for development when backend is not available
      final mockRoles = [
        {
          'value': 'admin',
          'label': 'System Administrator',
          'level': 7,
          'description': 'Full system access and user management capabilities',
        },
        {
          'value': 'chair',
          'label': 'Church Chair',
          'level': 6,
          'description': 'Leadership oversight and administrative functions',
        },
        {
          'value': 'pastor',
          'label': 'Senior Pastor',
          'level': 5,
          'description': 'Pastoral care and spiritual leadership',
        },
        {
          'value': 'church_elder',
          'label': 'Church Elder',
          'level': 4,
          'description': 'Elder responsibilities and guidance',
        },
        {
          'value': 'deacon',
          'label': 'Church Deacon',
          'level': 3,
          'description': 'Service ministry and support functions',
        },
        {
          'value': 'group_leader',
          'label': 'Group Leader',
          'level': 2,
          'description': 'Small group and ministry leadership',
        },
        {
          'value': 'member',
          'label': 'Church Member',
          'level': 1,
          'description': 'General church membership',
        },
      ];

      return ApiResponse(
        success: true,
        message: 'Mock roles loaded for development',
        statusCode: 200,
        data: mockRoles,
      );
    }
  }

  /// Get all users for role management
  static Future<ApiResponse> getAllUsers({
    String? role,
    String? search,
    int page = 1,
  }) async {
    try {
      var queryParams = <String, String>{'page': page.toString()};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('${ApiConfig.currentUrl}/admin/users')
          .replace(queryParameters: queryParams);
      
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          ...ApiConfig.authHeaders(token),
        },
      ).timeout(ApiConfig.requestTimeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get users: ${e.toString()}');
    }
  }

  /// Assign role to a single user
  static Future<ApiResponse> assignRole(
    int userId,
    String role, {
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{
        'role': role,
      };
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await _makeRequest(
        'PUT',
        '/admin/users/$userId/role',
        body: body,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to assign role: ${e.toString()}');
    }
  }

  /// Bulk assign roles to multiple users
  static Future<ApiResponse> bulkAssignRoles(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{
        'users': assignments,
      };
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await _makeRequest(
        'POST',
        '/admin/users/bulk-assign-roles',
        body: body,
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to bulk assign roles: ${e.toString()}');
    }
  }

  /// Get role change history for a user
  static Future<ApiResponse> getUserRoleHistory(int userId) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/admin/users/$userId/role-history',
      );

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Failed to get role history: ${e.toString()}');
    }
  }
}

/// Role model for UI
class Role {
  final String value;
  final String label;
  final int level;
  final String description;

  Role({
    required this.value,
    required this.label,
    required this.level,
    required this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      value: json['value'] as String,
      label: json['label'] as String,
      level: json['level'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'level': level,
      'description': description,
    };
  }

  @override
  String toString() => '$label (Level $level)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Role assignment model for bulk operations
class RoleAssignment {
  final int userId;
  final String role;
  final String? userName;
  final String? userEmail;

  RoleAssignment({
    required this.userId,
    required this.role,
    this.userName,
    this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
    };
  }

  @override
  String toString() => '$userName ($userEmail) -> $role';
}
