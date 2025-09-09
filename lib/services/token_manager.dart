import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Manager for secure token storage and retrieval
class TokenManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _refreshTokenKey = 'refresh_token';

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }

  /// Save user ID
  static Future<void> saveUserId(int userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId.toString());
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }

  /// Get stored user ID
  static Future<int?> getUserId() async {
    try {
      final userIdStr = await _storage.read(key: _userIdKey);
      return userIdStr != null ? int.tryParse(userIdStr) : null;
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (e) {
      throw Exception('Failed to save user email: $e');
    }
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      throw Exception('Failed to get user email: $e');
    }
  }

  /// Save refresh token (if using refresh tokens)
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  /// Remove authentication token
  static Future<void> removeToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to remove token: $e');
    }
  }

  /// Remove user ID
  static Future<void> removeUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      throw Exception('Failed to remove user ID: $e');
    }
  }

  /// Remove user email
  static Future<void> removeUserEmail() async {
    try {
      await _storage.delete(key: _userEmailKey);
    } catch (e) {
      throw Exception('Failed to remove user email: $e');
    }
  }

  /// Remove refresh token
  static Future<void> removeRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to remove refresh token: $e');
    }
  }

  /// Clear all stored authentication data
  static Future<void> clearAll() async {
    try {
      await Future.wait([
        removeToken(),
        removeUserId(),
        removeUserEmail(),
        removeRefreshToken(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Check if user has a valid token stored
  static Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in (has token and user ID)
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      return token != null && token.isNotEmpty && userId != null;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored authentication data
  static Future<Map<String, dynamic>> getAllAuthData() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      final email = await getUserEmail();
      final refreshToken = await getRefreshToken();

      return {
        'token': token,
        'userId': userId,
        'email': email,
        'refreshToken': refreshToken,
      };
    } catch (e) {
      throw Exception('Failed to get all auth data: $e');
    }
  }
}
