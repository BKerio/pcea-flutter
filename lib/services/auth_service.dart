import 'dart:async';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import 'api_service.dart';
import 'token_manager.dart';

/// Authentication state management service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Stream controllers for auth state
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  final StreamController<UserProfile?> _profileController = StreamController<UserProfile?>.broadcast();

  // Current state
  bool _isAuthenticated = false;
  User? _currentUser;
  UserProfile? _currentProfile;

  // Getters for streams
  Stream<bool> get authStateStream => _authStateController.stream;
  Stream<User?> get userStream => _userController.stream;
  Stream<UserProfile?> get profileStream => _profileController.stream;

  // Getters for current state
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  UserProfile? get currentProfile => _currentProfile;

  /// Initialize authentication service
  Future<void> initialize() async {
    try {
      // Check if user has stored token
      final hasToken = await TokenManager.hasValidToken();
      if (hasToken) {
        // Verify token with server and load user data
        await _loadUserData();
      }
    } catch (e) {
      print('Auth initialization error: $e');
      await _clearAuthState();
    }
  }

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.isSuccess) {
        await _handleSuccessfulAuth(response);
        return AuthResult.success('Registration successful');
      } else {
        return AuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return AuthResult.failure('Registration failed', [e.toString()]);
    }
  }

  /// Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response.isSuccess) {
        await _handleSuccessfulAuth(response);
        return AuthResult.success('Login successful');
      } else {
        return AuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return AuthResult.failure('Login failed', [e.toString()]);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call API logout (this also clears tokens)
      await ApiService.logout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      // Always clear local state
      await _clearAuthState();
    }
  }

  /// Load current user profile
  Future<AuthResult> loadProfile() async {
    try {
      final response = await ApiService.getUserProfile();
      
      if (response.isSuccess && response.data != null) {
        _currentProfile = UserProfile.fromJson(response.data['profile']);
        _profileController.add(_currentProfile);
        return AuthResult.success('Profile loaded successfully');
      } else {
        return AuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return AuthResult.failure('Failed to load profile', [e.toString()]);
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile(UserProfile profile) async {
    try {
      final response = await ApiService.updateProfile(profile);
      
      if (response.isSuccess && response.data != null) {
        _currentProfile = UserProfile.fromJson(response.data['profile']);
        _profileController.add(_currentProfile);
        return AuthResult.success('Profile updated successfully');
      } else {
        return AuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return AuthResult.failure('Failed to update profile', [e.toString()]);
    }
  }

  /// Update profile with custom data
  Future<AuthResult> updateProfileData(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.updateProfileData(data);
      
      if (response.isSuccess && response.data != null) {
        _currentProfile = UserProfile.fromJson(response.data['profile']);
        _profileController.add(_currentProfile);
        return AuthResult.success('Profile updated successfully');
      } else {
        return AuthResult.failure(response.message, response.errorMessages);
      }
    } catch (e) {
      return AuthResult.failure('Failed to update profile', [e.toString()]);
    }
  }

  /// Refresh authentication data
  Future<void> refreshAuth() async {
    if (_isAuthenticated) {
      await _loadUserData();
    }
  }

  /// Check if user needs to complete profile
  bool get needsProfileCompletion {
    if (_currentProfile == null) return true;
    
    // Check if essential profile fields are missing
    return _currentProfile!.phone == null || 
           _currentProfile!.dateOfBirth == null;
  }

  /// Handle successful authentication response
  Future<void> _handleSuccessfulAuth(ApiResponse response) async {
    if (response.data != null && response.data['user'] != null) {
      try {
        _currentUser = User.fromJson(response.data['user']);
        _isAuthenticated = true;
        
        // Notify listeners
        _authStateController.add(_isAuthenticated);
        _userController.add(_currentUser);
        
        // Load profile data
        await loadProfile();
      } catch (e) {
        print('Error parsing user data: $e');
        print('User data received: ${response.data['user']}');
        throw Exception('Failed to parse user data: ${e.toString()}');
      }
    }
  }

  /// Get the appropriate dashboard route for the current user
  String? get dashboardRoute {
    if (_currentUser == null) return null;
    return _currentUser!.dashboardRoute ?? _getDashboardRouteForRole(_currentUser!.role);
  }

  /// Get dashboard route based on role
  String _getDashboardRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return '/admin/dashboard';
      case 'chair':
        return '/chair/dashboard';
      case 'pastor':
        return '/pastor/dashboard';
      case 'church_elder':
        return '/elder/dashboard';
      case 'deacon':
        return '/deacon/dashboard';
      case 'group_leader':
        return '/leader/dashboard';
      case 'member':
      default:
        return '/member/dashboard';
    }
  }

  /// Load user data from API
  Future<void> _loadUserData() async {
    try {
      // Get basic user info
      final userResponse = await ApiService.getUser();
      if (userResponse.isSuccess && userResponse.data != null) {
        try {
          _currentUser = User.fromJson(userResponse.data['user']);
          _isAuthenticated = true;
          
          // Notify listeners
          _authStateController.add(_isAuthenticated);
          _userController.add(_currentUser);
          
          // Load profile data
          await loadProfile();
        } catch (parseError) {
          print('Error parsing user data in _loadUserData: $parseError');
          print('User data: ${userResponse.data['user']}');
          await _clearAuthState();
        }
      } else {
        await _clearAuthState();
      }
    } catch (e) {
      print('Load user data error: $e');
      await _clearAuthState();
    }
  }

  /// Clear authentication state
  Future<void> _clearAuthState() async {
    _isAuthenticated = false;
    _currentUser = null;
    _currentProfile = null;
    
    // Clear stored tokens
    await TokenManager.clearAll();
    
    // Notify listeners
    _authStateController.add(_isAuthenticated);
    _userController.add(_currentUser);
    _profileController.add(_currentProfile);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
    _userController.close();
    _profileController.close();
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String message;
  final List<String> errors;

  AuthResult._({
    required this.success,
    required this.message,
    required this.errors,
  });

  factory AuthResult.success(String message) {
    return AuthResult._(
      success: true,
      message: message,
      errors: [],
    );
  }

  factory AuthResult.failure(String message, [List<String>? errors]) {
    return AuthResult._(
      success: false,
      message: message,
      errors: errors ?? [],
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  String get firstError => errors.isNotEmpty ? errors.first : message;
}
