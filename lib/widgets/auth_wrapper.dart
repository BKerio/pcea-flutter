import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/user_profile.dart';

/// Authentication wrapper that manages user state across the app
class AuthWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  late Stream<bool> _authStream;
  late Stream<User?> _userStream;
  late Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    _authStream = _authService.authStateStream;
    _userStream = _authService.userStream;
    _profileStream = _authService.profileStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        return StreamBuilder<User?>(
          stream: _userStream,
          builder: (context, userSnapshot) {
            return StreamBuilder<UserProfile?>(
              stream: _profileStream,
              builder: (context, profileSnapshot) {
                // Provide auth context to child widgets
                return AuthProvider(
                  isAuthenticated: authSnapshot.data ?? false,
                  user: userSnapshot.data,
                  profile: profileSnapshot.data,
                  authService: _authService,
                  child: widget.child,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// InheritedWidget to provide authentication context
class AuthProvider extends InheritedWidget {
  final bool isAuthenticated;
  final User? user;
  final UserProfile? profile;
  final AuthService authService;

  const AuthProvider({
    Key? key,
    required this.isAuthenticated,
    required this.user,
    required this.profile,
    required this.authService,
    required Widget child,
  }) : super(key: key, child: child);

  static AuthProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
  }

  /// Check if user needs to complete their profile
  bool get needsProfileCompletion {
    if (!isAuthenticated || profile == null) return false;
    
    // Check if essential profile fields are missing
    return profile!.phone == null || 
           profile!.dateOfBirth == null ||
           (profile!.phone?.isEmpty ?? true);
  }

  /// Get user display name
  String get displayName {
    return user?.name ?? 'User';
  }

  /// Get user email
  String get userEmail {
    return user?.email ?? '';
  }

  @override
  bool updateShouldNotify(AuthProvider oldWidget) {
    return oldWidget.isAuthenticated != isAuthenticated ||
           oldWidget.user != user ||
           oldWidget.profile != profile;
  }
}

/// Helper widget to handle authentication requirements
class RequireAuth extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final String? redirectRoute;

  const RequireAuth({
    Key? key,
    required this.child,
    this.fallback,
    this.redirectRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    
    if (authProvider?.isAuthenticated == true) {
      return child;
    }
    
    // If redirect route is provided, navigate there
    if (redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(redirectRoute!);
      });
    }
    
    // Return fallback widget or default message
    return fallback ?? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please log in to access this feature',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for profile completion prompt
class ProfileCompletionPrompt extends StatelessWidget {
  final Widget child;
  final bool showPrompt;

  const ProfileCompletionPrompt({
    Key? key,
    required this.child,
    this.showPrompt = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    
    if (!showPrompt || !authProvider!.needsProfileCompletion) {
      return child;
    }

    return Column(
      children: [
        // Profile completion banner
        Container(
          width: double.infinity,
          color: Colors.orange.shade100,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete your profile to unlock all features',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to profile completion
                  _showProfileCompletionDialog(context);
                },
                child: Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  void _showProfileCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: const Text(
          'To fully enjoy all features of the PCEA Church app, please complete your profile with additional information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to profile editing screen
              // You can implement this based on your app structure
            },
            child: const Text('Complete Now'),
          ),
        ],
      ),
    );
  }
}
