import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/role_change.dart';
import 'token_manager.dart';

/// Role History Service for tracking and retrieving role changes
class RoleHistoryService {
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

  // ========== ROLE HISTORY ENDPOINTS ==========

  /// Get role history for a specific user
  /// [userId] - The ID of the user to get role history for
  /// [page] - Page number for pagination (defaults to 1)
  /// [perPage] - Items per page (defaults to 20)
  static Future<ApiResponse> getUserRoleHistory(
    int userId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final endpoint = '/admin/users/$userId/role-history?$queryString';
      final response = await _makeRequest('GET', endpoint);
      
      final apiResponse = ApiResponse.fromResponse(response);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        // Convert data to RoleHistoryResponse for easier access
        final roleHistoryResponse = RoleHistoryResponse.fromJson(apiResponse.data);
        return ApiResponse(
          success: true,
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          data: roleHistoryResponse,
        );
      } else {
        return ApiResponse(
          success: false,
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errors,
        );
      }
    } catch (e) {
      print('Error getting role history: $e');
      return ApiResponse.error('Failed to load role history: ${e.toString()}');
    }
  }

  /// Get system-wide role change statistics
  static Future<ApiResponse> getRoleStatistics() async {
    try {
      final response = await _makeRequest('GET', '/admin/role-statistics');
      final apiResponse = ApiResponse.fromResponse(response);
      
      return apiResponse;
    } catch (e) {
      print('Error getting role statistics: $e');
      return ApiResponse.error('Failed to load role statistics: ${e.toString()}');
    }
  }

  /// Get role history for multiple users (for admin overview)
  static Future<ApiResponse> getRecentRoleChanges({
    int limit = 50,
    String? roleFilter,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (roleFilter != null && roleFilter.isNotEmpty) {
        queryParams['role'] = roleFilter;
      }
      
      if (fromDate != null) {
        queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      }
      
      if (toDate != null) {
        queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final endpoint = '/admin/recent-role-changes?$queryString';
      final response = await _makeRequest('GET', endpoint);
      
      final apiResponse = ApiResponse.fromResponse(response);
      
      if (apiResponse.isSuccess && apiResponse.data != null) {
        try {
          final List<dynamic> changesData = apiResponse.data['changes'] ?? [];
          final roleChanges = changesData
              .map((json) => RoleChange.fromJson(json))
              .toList();
          
          return ApiResponse(
            success: true,
            message: apiResponse.message,
            statusCode: apiResponse.statusCode,
            data: roleChanges,
          );
        } catch (e) {
          print('Error parsing role changes: $e');
          return ApiResponse.error('Failed to parse role changes');
        }
      } else {
        return apiResponse;
      }
    } catch (e) {
      print('Error getting recent role changes: $e');
      return ApiResponse.error('Failed to load recent role changes: ${e.toString()}');
    }
  }

  /// Export role history data (returns CSV format)
  static Future<ApiResponse> exportRoleHistory({
    int? userId,
    DateTime? fromDate,
    DateTime? toDate,
    String format = 'csv',
  }) async {
    try {
      final queryParams = <String, String>{
        'format': format,
      };
      
      if (userId != null) {
        queryParams['user_id'] = userId.toString();
      }
      
      if (fromDate != null) {
        queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      }
      
      if (toDate != null) {
        queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final endpoint = '/admin/export-role-history?$queryString';
      final response = await _makeRequest('GET', endpoint);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Role history exported successfully',
          statusCode: response.statusCode,
          data: response.body,
        );
      } else {
        final apiResponse = ApiResponse.fromResponse(response);
        return apiResponse;
      }
    } catch (e) {
      print('Error exporting role history: $e');
      return ApiResponse.error('Failed to export role history: ${e.toString()}');
    }
  }

  /// Search users by role change history
  /// This helps find users who had specific role transitions
  static Future<ApiResponse> searchByRoleTransition({
    required String fromRole,
    required String toRole,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'from_role': fromRole,
        'to_role': toRole,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (fromDate != null) {
        queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
      }
      
      if (toDate != null) {
        queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
      }
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final endpoint = '/admin/search-role-transitions?$queryString';
      final response = await _makeRequest('GET', endpoint);
      
      final apiResponse = ApiResponse.fromResponse(response);
      return apiResponse;
    } catch (e) {
      print('Error searching role transitions: $e');
      return ApiResponse.error('Failed to search role transitions: ${e.toString()}');
    }
  }
}
