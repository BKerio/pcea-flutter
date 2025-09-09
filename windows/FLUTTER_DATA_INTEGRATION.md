# 📱 Flutter Frontend Data Integration Guide

## 🔗 Backend API Integration Specifications

This document provides detailed specifications for how your Flutter frontend should receive and handle data from the Laravel backend.

---

## 🌐 Base Configuration

### API Base URL
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-server-ip:8080/api';
  
  // For development (local testing)
  static const String devUrl = 'http://127.0.0.1:8080/api';
  
  // For production
  static const String prodUrl = 'https://your-domain.com/api';
}
```

### Required Headers
```dart
Map<String, String> get defaultHeaders => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

Map<String, String> authHeaders(String token) => {
  ...defaultHeaders,
  'Authorization': 'Bearer $token',
};
```

---

## 📡 API Response Structure

**ALL API responses follow this consistent format:**

```json
{
  "success": true,
  "message": "Description of the result",
  "data": {
    // Response data (when success = true)
  },
  "errors": {
    // Validation errors (when success = false)
  }
}
```

### Success Response Example
```json
{
  "success": true,
  "message": "User logged in successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "access_token": "1|AbCdEf...",
    "token_type": "Bearer"
  }
}
```

### Error Response Example
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

---

## 🔐 Authentication Endpoints

### 1. User Registration
**Endpoint:** `POST /api/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    },
    "access_token": "1|AbCdEfGhIjKlMnOpQrStUvWxYz...",
    "token_type": "Bearer"
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirmation,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/register'),
    headers: ApiConfig.defaultHeaders,
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }),
  );
  
  return jsonDecode(response.body);
}
```

### 2. User Login
**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    },
    "access_token": "2|BcDeFgHiJkLmNoPqRsTuVwXyZ...",
    "token_type": "Bearer"
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/login'),
    headers: ApiConfig.defaultHeaders,
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  return jsonDecode(response.body);
}
```

### 3. User Logout
**Endpoint:** `POST /api/logout`
**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> logout(String token) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/logout'),
    headers: ApiConfig.authHeaders(token),
  );
  
  return jsonDecode(response.body);
}
```

---

## 👤 User Management Endpoints

### 1. Get Basic User Profile
**Endpoint:** `GET /api/user`
**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    }
  }
}
```

### 2. Get Extended User Profile
**Endpoint:** `GET /api/profile`
**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    },
    "profile": {
      "id": 1,
      "user_id": 1,
      "phone": "+1234567890",
      "date_of_birth": "1990-01-15",
      "gender": "male",
      "bio": "Flutter developer passionate about mobile apps",
      "profile_picture": null,
      "location": "New York, USA",
      "preferences": {
        "theme": "dark",
        "notifications": true,
        "language": "en"
      },
      "is_active": true,
      "last_login_at": "2025-09-09T10:30:00.000000Z",
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    }
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getExtendedProfile(String token) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/profile'),
    headers: ApiConfig.authHeaders(token),
  );
  
  return jsonDecode(response.body);
}
```

### 3. Update User Profile
**Endpoint:** `PUT /api/profile`
**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "phone": "+1234567890",
  "date_of_birth": "1990-01-15",
  "gender": "male",
  "bio": "Updated bio text",
  "location": "San Francisco, CA",
  "preferences": {
    "theme": "dark",
    "notifications": true,
    "language": "en"
  }
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "profile": {
      "id": 1,
      "user_id": 1,
      "phone": "+1234567890",
      "date_of_birth": "1990-01-15",
      "gender": "male",
      "bio": "Updated bio text",
      "profile_picture": null,
      "location": "San Francisco, CA",
      "preferences": {
        "theme": "dark",
        "notifications": true,
        "language": "en"
      },
      "is_active": true,
      "last_login_at": "2025-09-09T10:30:00.000000Z",
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T11:45:00.000000Z"
    }
  }
}
```

---

## 📱 Device Token Management

### 1. Register Device Token for Push Notifications
**Endpoint:** `POST /api/device-tokens`
**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "device_token": "fcm_token_here_very_long_string...",
  "device_type": "mobile",
  "platform": "android",
  "app_version": "1.0.0"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Device token registered successfully",
  "data": {
    "device_token": {
      "id": 1,
      "user_id": 1,
      "device_token": "fcm_token_here_very_long_string...",
      "device_type": "mobile",
      "platform": "android",
      "app_version": "1.0.0",
      "is_active": true,
      "last_used_at": "2025-09-09T10:30:00.000000Z",
      "created_at": "2025-09-09T10:30:00.000000Z",
      "updated_at": "2025-09-09T10:30:00.000000Z"
    }
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> registerDeviceToken({
  required String token,
  required String deviceToken,
  String deviceType = 'mobile',
  String? platform,
  String? appVersion,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/device-tokens'),
    headers: ApiConfig.authHeaders(token),
    body: jsonEncode({
      'device_token': deviceToken,
      'device_type': deviceType,
      'platform': platform,
      'app_version': appVersion,
    }),
  );
  
  return jsonDecode(response.body);
}
```

### 2. Remove Device Token
**Endpoint:** `DELETE /api/device-tokens/{token}`
**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Device token removed successfully",
  "data": null
}
```

---

## ⚙️ App Configuration Endpoints

### 1. Get App Configuration
**Endpoint:** `GET /api/config`
**Authentication:** Not required (Public)

**Success Response (200):**
```json
{
  "success": true,
  "message": "App configuration retrieved successfully",
  "data": {
    "app_name": "PCEA App",
    "app_version": "1.0.0",
    "api_version": "v1",
    "maintenance_mode": false,
    "maintenance_message": "App is under maintenance. Please try again later.",
    "force_update": false,
    "min_version": "1.0.0",
    "latest_version": "1.0.0",
    "welcome_message": "Welcome to PCEA App!",
    "terms_url": "https://example.com/terms",
    "privacy_url": "https://example.com/privacy"
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getAppConfig() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/config'),
    headers: ApiConfig.defaultHeaders,
  );
  
  return jsonDecode(response.body);
}

// Usage in Flutter
void checkAppConfig() async {
  final config = await getAppConfig();
  
  if (config['success']) {
    final data = config['data'];
    
    // Check maintenance mode
    if (data['maintenance_mode']) {
      // Show maintenance screen with message
      showMaintenanceScreen(data['maintenance_message']);
      return;
    }
    
    // Check for force update
    if (data['force_update']) {
      final currentVersion = await getCurrentAppVersion();
      if (isVersionOlder(currentVersion, data['min_version'])) {
        showForceUpdateDialog();
        return;
      }
    }
    
    // Continue with normal app flow
    proceedToMainApp();
  }
}
```

### 2. Health Check
**Endpoint:** `GET /api/health`
**Authentication:** Not required (Public)

**Success Response (200):**
```json
{
  "success": true,
  "message": "API is healthy",
  "data": {
    "status": "healthy",
    "timestamp": "2025-09-09T10:30:00.000000Z",
    "version": "1.0.0"
  }
}
```

### 3. Server Time
**Endpoint:** `GET /api/time`
**Authentication:** Not required (Public)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Server time retrieved successfully",
  "data": {
    "server_time": "2025-09-09T10:30:00.000000Z",
    "timezone": "UTC"
  }
}
```

---

## 🔄 Complete Flutter API Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api';
  
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // Authentication
  static Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    
    return ApiResponse.fromResponse(response);
  }

  static Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _defaultHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return ApiResponse.fromResponse(response);
  }

  static Future<ApiResponse> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _authHeaders(token),
    );
    
    return ApiResponse.fromResponse(response);
  }

  // User Profile
  static Future<ApiResponse> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders(token),
    );
    
    return ApiResponse.fromResponse(response);
  }

  static Future<ApiResponse> updateProfile(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    
    return ApiResponse.fromResponse(response);
  }

  // Device Tokens
  static Future<ApiResponse> registerDeviceToken(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/device-tokens'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    
    return ApiResponse.fromResponse(response);
  }

  // App Configuration
  static Future<ApiResponse> getAppConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/config'),
      headers: _defaultHeaders,
    );
    
    return ApiResponse.fromResponse(response);
  }

  static Future<ApiResponse> healthCheck() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: _defaultHeaders,
    );
    
    return ApiResponse.fromResponse(response);
  }
}

// API Response wrapper class
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

  factory ApiResponse.fromResponse(http.Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    
    return ApiResponse(
      success: body['success'] ?? false,
      message: body['message'] ?? '',
      data: body['data'],
      errors: body['errors'],
      statusCode: response.statusCode,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}
```

---

## 🛡️ Error Handling

### Common HTTP Status Codes
- **200**: Success
- **201**: Created (successful registration)
- **400**: Bad Request
- **401**: Unauthorized (invalid token)
- **422**: Validation Error
- **429**: Too Many Requests (rate limiting)
- **500**: Internal Server Error

### Error Handling in Flutter
```dart
Future<void> handleApiCall() async {
  try {
    final response = await ApiService.login(
      email: 'test@example.com',
      password: 'password123',
    );
    
    if (response.isSuccess) {
      // Handle success
      final token = response.data['access_token'];
      final user = response.data['user'];
      await saveUserData(token, user);
      navigateToHome();
    } else {
      // Handle API error
      if (response.hasErrors) {
        // Show validation errors
        showValidationErrors(response.errors!);
      } else {
        // Show general error message
        showErrorMessage(response.message);
      }
    }
  } catch (e) {
    // Handle network or other errors
    showErrorMessage('Network error: Please check your connection');
  }
}
```

---

## 🔒 Token Management

### Storing Tokens Securely
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
```

---

## 📋 Data Models

### User Model
```dart
class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

### User Profile Model
```dart
class UserProfile {
  final int id;
  final int userId;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bio;
  final String? profilePicture;
  final String? location;
  final Map<String, dynamic>? preferences;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.profilePicture,
    this.location,
    this.preferences,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      location: json['location'],
      preferences: json['preferences'],
      isActive: json['is_active'] ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

---

## 🚀 Getting Started Checklist

### 1. Flutter Dependencies
Add these to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
```

### 2. Network Configuration
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<application android:usesCleartextTraffic="true">
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 3. Test Your Connection
```dart
void main() async {
  // Test API connection
  final health = await ApiService.healthCheck();
  print('API Health: ${health.isSuccess}');
  
  runApp(MyApp());
}
```

---

## 📞 Support & Testing

### Test Your APIs
Your Laravel server should be running on: `http://127.0.0.1:8080`

**Available test endpoints:**
- GET `http://127.0.0.1:8080/api/health`
- GET `http://127.0.0.1:8080/api/config`
- GET `http://127.0.0.1:8080/api/test`

### Troubleshooting
1. **Connection refused**: Make sure Laravel server is running
2. **CORS errors**: CORS is already configured in your backend
3. **401 Unauthorized**: Check if token is included in headers
4. **422 Validation**: Check request body format and required fields

---

Your Flutter app is now ready to integrate with the Laravel backend! All endpoints provide consistent data structures and comprehensive error handling. 🎉
