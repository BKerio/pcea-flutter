# 🚀 Flutter API Integration Setup

This document explains how to use the API integration setup for your PCEA Flutter app.

## 📁 File Structure

```
lib/
├── config/
│   └── api_config.dart           # API configuration and URLs
├── models/
│   ├── api_response.dart         # API response wrapper
│   ├── user.dart                 # User model
│   └── user_profile.dart         # User profile model
├── services/
│   ├── api_service.dart          # Main API service
│   ├── auth_service.dart         # Authentication management
│   ├── token_manager.dart        # Secure token storage
│   └── app_config_service.dart   # App configuration service
├── screens/
│   └── auth_screens.dart         # Login and Registration screens
├── main.dart                     # Your existing main file
└── main_with_api.dart           # Enhanced main with API integration
```

## 🔧 Setup Instructions

### 1. Install Dependencies

Make sure your `pubspec.yaml` includes these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.5.0
  shared_preferences: ^2.3.2
  flutter_launcher_icons: ^0.14.4
  google_fonts: ^6.2.1
  flutter_secure_storage: ^9.0.0  # Added for secure token storage
```

Then run:
```bash
flutter pub get
```

### 2. Configure Network Permissions

**For Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<application android:usesCleartextTraffic="true">
```

**For iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 3. Update API Configuration

Edit `lib/config/api_config.dart` and update the URLs:

```dart
class ApiConfig {
  // For development (local testing)
  static const String devUrl = 'http://127.0.0.1:8080/api';
  
  // For production - UPDATE THIS with your actual production URL
  static const String prodUrl = 'https://your-domain.com/api';
  
  // Change to 'production' for production builds
  static const String environment = 'development';
}
```

### 4. Replace Your Main File

You have two options:

**Option A: Replace your existing main.dart**
- Backup your current `lib/main.dart`
- Copy content from `lib/main_with_api.dart` to `lib/main.dart`

**Option B: Use the enhanced main file**
- Keep your existing `lib/main.dart`
- Use `lib/main_with_api.dart` as reference
- Integrate the authentication and API logic into your existing app

## 📱 Usage Examples

### 1. Basic API Connection Test

```dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void testApiConnection() async {
  final isConnected = await ApiService.testConnection();
  print('API Connected: $isConnected');
}
```

### 2. User Authentication

```dart
import 'services/auth_service.dart';

class LoginExample extends StatefulWidget {
  @override
  _LoginExampleState createState() => _LoginExampleState();
}

class _LoginExampleState extends State<LoginExample> {
  final _authService = AuthService();

  Future<void> loginUser(String email, String password) async {
    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result.success) {
      // Login successful
      print('Welcome ${_authService.currentUser?.name}!');
      // Navigate to home screen
    } else {
      // Show error
      print('Login failed: ${result.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authService.authStateStream,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data ?? false;
        
        if (isLoggedIn) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
```

### 3. User Registration

```dart
Future<void> registerUser() async {
  final authService = AuthService();
  
  final result = await authService.register(
    name: 'John Doe',
    email: 'john@example.com',
    password: 'password123',
    passwordConfirmation: 'password123',
  );

  if (result.success) {
    print('Registration successful!');
    // User is automatically logged in after registration
  } else {
    print('Registration failed: ${result.firstError}');
  }
}
```

### 4. Profile Management

```dart
import 'models/user_profile.dart';
import 'services/auth_service.dart';

Future<void> updateUserProfile() async {
  final authService = AuthService();
  
  // Update profile data
  final profileData = {
    'phone': '+1234567890',
    'date_of_birth': '1990-01-15',
    'gender': 'male',
    'location': 'Nairobi, Kenya',
    'bio': 'Member of PCEA Church',
    'preferences': {
      'theme': 'light',
      'notifications': true,
      'language': 'en',
    },
  };
  
  final result = await authService.updateProfileData(profileData);
  
  if (result.success) {
    print('Profile updated successfully!');
    print('User profile: ${authService.currentProfile}');
  } else {
    print('Profile update failed: ${result.message}');
  }
}
```

### 5. App Configuration

```dart
import 'services/app_config_service.dart';

Future<void> checkAppConfiguration() async {
  final configService = AppConfigService();
  
  // Check if app is in maintenance mode
  final isMaintenanceMode = await configService.isMaintenanceMode();
  if (isMaintenanceMode) {
    final message = await configService.getMaintenanceMessage();
    // Show maintenance screen
    return;
  }
  
  // Check if force update is required
  const currentVersion = '1.0.0'; // Get from package_info_plus
  final needsUpdate = await configService.isForceUpdateRequired(currentVersion);
  if (needsUpdate) {
    // Show update required screen
    return;
  }
  
  // Continue with normal app flow
}
```

### 6. Logout

```dart
Future<void> logoutUser() async {
  final authService = AuthService();
  await authService.logout();
  
  // User is automatically logged out and tokens are cleared
  // Navigate to welcome/login screen
}
```

## 🔐 Authentication State Management

The `AuthService` provides real-time authentication state through streams:

```dart
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthService().authStateStream,
      builder: (context, snapshot) {
        final isAuthenticated = snapshot.data ?? false;
        
        return MaterialApp(
          home: isAuthenticated ? HomeScreen() : WelcomeScreen(),
        );
      },
    );
  }
}
```

## 🛡️ Error Handling

All API calls return an `AuthResult` or `ApiResponse` with comprehensive error information:

```dart
final result = await authService.login(email: email, password: password);

if (result.success) {
  // Handle success
  print('Success: ${result.message}');
} else {
  // Handle error
  if (result.hasErrors) {
    // Show validation errors
    for (String error in result.errors) {
      print('Error: $error');
    }
  } else {
    // Show general error
    print('Error: ${result.message}');
  }
}
```

## 🚀 Running Your App

1. **Start your Laravel backend server:**
   ```bash
   php artisan serve --host=127.0.0.1 --port=8080
   ```

2. **Test API connection:**
   ```bash
   curl http://127.0.0.1:8080/api/health
   ```

3. **Run your Flutter app:**
   ```bash
   flutter run
   ```

## 🔧 Environment Configuration

For production builds, make sure to:

1. Update `ApiConfig.environment` to `'production'`
2. Set the correct production URL in `ApiConfig.prodUrl`
3. Remove `android:usesCleartextTraffic="true"` for production Android builds
4. Use HTTPS URLs for production

## 📋 Testing Endpoints

Your Laravel backend provides these test endpoints:

- **Health Check:** `GET /api/health`
- **App Config:** `GET /api/config`
- **Server Time:** `GET /api/time`

Test them with:
```bash
curl http://127.0.0.1:8080/api/health
curl http://127.0.0.1:8080/api/config
```

## 🤝 Integration with Existing Screens

To integrate with your existing screens (Welcome, GetStarted, etc.):

1. Import the auth service in your existing screens
2. Add authentication checks where needed
3. Use the provided login/register screens or create your own
4. Listen to auth state changes to handle navigation

Example integration in your Welcome screen:
```dart
// In your welcome.dart
import '../services/auth_service.dart';

// Add this to check if user is already logged in
@override
void initState() {
  super.initState();
  _checkAuthStatus();
}

void _checkAuthStatus() async {
  final authService = AuthService();
  if (authService.isAuthenticated) {
    // User is already logged in, navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

## 🎯 Next Steps

1. **Test the API integration** with your Laravel backend
2. **Customize the UI** of the login/register screens to match your design
3. **Add more API endpoints** as needed for your app features
4. **Implement push notifications** using the device token registration
5. **Add offline support** using local storage for cached data

Your Flutter app is now fully integrated with the Laravel backend API! 🎉
