import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Response wrapper class that handles all API responses consistently
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
    this.errors,
  });

  /// Create ApiResponse from HTTP response
  factory ApiResponse.fromResponse(http.Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      
      return ApiResponse(
        success: body['success'] ?? false,
        message: body['message'] ?? 'Unknown error occurred',
        data: body['data'],
        errors: body['errors'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
        data: null,
        errors: null,
      );
    }
  }

  /// Create error response for exceptions
  factory ApiResponse.error(String message, {int statusCode = 0}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      data: null,
      errors: null,
    );
  }

  /// Check if response is successful (both API success and HTTP success)
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  
  /// Check if response has validation errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Get formatted error messages
  List<String> get errorMessages {
    if (!hasErrors) return [];
    
    List<String> messages = [];
    errors!.forEach((field, fieldErrors) {
      if (fieldErrors is List) {
        messages.addAll(fieldErrors.cast<String>());
      } else {
        messages.add(fieldErrors.toString());
      }
    });
    return messages;
  }

  /// Get first error message
  String get firstError {
    if (!hasErrors) return message;
    return errorMessages.first;
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, statusCode: $statusCode, hasErrors: $hasErrors}';
  }
}
