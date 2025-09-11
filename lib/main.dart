import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/splash_screen.dart';
import 'screen/welcome.dart';
import 'services/auth_service.dart';
import 'services/app_config_service.dart';
import 'services/api_service.dart';
import 'screens/auth_screens.dart';
import 'screen/staff_role.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/chair_dashboard.dart';
import 'dashboards/pastor_dashboard.dart';
import 'dashboards/elder_dashboard.dart';
import 'dashboards/deacon_dashboard.dart';
import 'dashboards/group_leader_dashboard.dart';
import 'dashboards/member_dashboard.dart';
import 'screens/admin_user_management.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  try {
    // Initialize authentication service
    final authService = AuthService();
    await authService.initialize();
    
    // Test API connection
    final isConnected = await ApiService.testConnection();
    if (kDebugMode) {
      print('API Connection: ${isConnected ? 'Connected' : 'Failed'}');
    }
    
    // Get app configuration
    final configService = AppConfigService();
    final config = await configService.getConfig();
    if (kDebugMode) {
      print('App Config: ${config?.appName ?? 'Not loaded'}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = Theme.of(context).textTheme;

    final headlineFont = GoogleFonts.poppinsTextTheme(baseTextTheme);
    final bodyFont = GoogleFonts.robotoTextTheme(baseTextTheme);
    final _ = GoogleFonts.sourceCodeProTextTheme(baseTextTheme);

    final mergedTextTheme = bodyFont
        .copyWith(
          displayLarge: headlineFont.displayLarge,
          displayMedium: headlineFont.displayMedium,
          displaySmall: headlineFont.displaySmall,
          headlineLarge: headlineFont.headlineLarge,
          headlineMedium: headlineFont.headlineMedium,
          headlineSmall: headlineFont.headlineSmall,
          titleLarge: headlineFont.titleLarge,
          titleMedium: headlineFont.titleMedium,
          titleSmall: headlineFont.titleSmall,
          labelLarge: headlineFont.labelLarge,
          labelMedium: headlineFont.labelMedium,
          labelSmall: headlineFont.labelSmall,
          bodySmall: bodyFont.bodySmall,
          bodyMedium: bodyFont.bodyMedium,
          bodyLarge: bodyFont.bodyLarge,
        )
        .apply(
          // Default color tweaks can go here if needed
        );

    final appTheme = ThemeData(
      useMaterial3: true,
      textTheme: mergedTextTheme,
      primaryTextTheme: mergedTextTheme,
      typography: Typography.material2021(platform: defaultTargetPlatform),
    );

    return MaterialApp(
      title: 'PCEA Church App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AppInitializer(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/staff-roles': (context) => const LandingScreen(),
        '/home': (context) => const LandingScreen(), // Alias for staff-roles
        // Role-based dashboards
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/chair/dashboard': (context) => const ChairDashboard(),
        '/pastor/dashboard': (context) => const PastorDashboard(),
        '/elder/dashboard': (context) => const ElderDashboard(),
        '/deacon/dashboard': (context) => const DeaconDashboard(),
        '/leader/dashboard': (context) => const GroupLeaderDashboard(),
        '/member/dashboard': (context) => const MemberDashboard(),
        // Admin management screens
        '/admin/user-management': (context) => const AdminUserManagement(),
      },
    );
  }
}

/// App initializer that handles startup logic and authentication
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and check authentication status
  Future<void> _initializeApp() async {
    try {
      // Show splash screen for a minimum time
      await Future.delayed(const Duration(seconds: 2));

      // Check app configuration
      final configService = AppConfigService();
      final config = await configService.getConfig();
      
      // Check for maintenance mode
      if (config?.maintenanceMode == true) {
        if (mounted) {
          _showMaintenanceScreen(config!.maintenanceMessage);
        }
        return;
      }
      
      // Check authentication status
      final authService = AuthService();
      
      if (authService.isAuthenticated) {
        // User is logged in, navigate to their role-specific dashboard
        final dashboardRoute = authService.dashboardRoute ?? '/member/dashboard';
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(dashboardRoute);
        }
      } else {
        // User is not logged in, go to welcome
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/welcome');
        }
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// Show maintenance screen
  void _showMaintenanceScreen(String? message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Maintenance'),
        content: Text(message ?? 'App is under maintenance. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = '';
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show splash screen while initializing
    return const SplashScreen();
  }
}
