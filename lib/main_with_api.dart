import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your existing screens
import 'screen/splash_screen.dart';
import 'screen/welcome.dart';
import 'screen/get_started.dart';

// Import new API services and auth screens
import 'services/auth_service.dart';
import 'services/app_config_service.dart';
import 'services/api_service.dart';
import 'screens/auth_screens.dart';

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
        );

    final appTheme = ThemeData(
      useMaterial3: true,
      textTheme: mergedTextTheme,
      primaryTextTheme: mergedTextTheme,
      typography: Typography.material2021(platform: defaultTargetPlatform),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );

    final darkAppTheme = ThemeData(
      useMaterial3: true,
      textTheme: mergedTextTheme,
      primaryTextTheme: mergedTextTheme,
      typography: Typography.material2021(platform: defaultTargetPlatform),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'PCEA Church App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.system,
      
      // Define routes
      routes: {
        '/': (context) => const AppInitializer(),
        '/welcome': (context) => const WelcomeScreen(),
        '/get-started': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(), // You'll create this
      },
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}

/// App initializer that handles startup logic
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
      // Check app configuration first
      final configService = AppConfigService();
      final config = await configService.getConfig();
      
      // Check for maintenance mode
      if (config?.maintenanceMode == true) {
        _showMaintenanceScreen(config!.maintenanceMessage);
        return;
      }
      
      // Check for force update
      // You would get current version from package_info_plus
      const currentVersion = '1.0.0'; // Replace with actual version
      final needsUpdate = await configService.isForceUpdateRequired(currentVersion);
      if (needsUpdate) {
        _showUpdateScreen();
        return;
      }
      
      // Check authentication status
      final authService = AuthService();
      
      // Listen to auth state changes
      authService.authStateStream.listen((isAuthenticated) {
        if (mounted) {
          if (isAuthenticated) {
            // User is logged in, go to home
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            // User is not logged in, go to welcome/login
            Navigator.of(context).pushReplacementNamed('/welcome');
          }
        }
      });
      
      // Initial check
      if (authService.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  /// Show maintenance screen
  void _showMaintenanceScreen(String? message) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MaintenanceScreen(message: message),
      ),
    );
  }

  /// Show update screen
  void _showUpdateScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const UpdateRequiredScreen(),
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

/// Temporary home screen placeholder
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCEA Church'),
        actions: [
          IconButton(
            onPressed: () async {
              // Show logout confirmation
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                final authService = AuthService();
                await authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: AuthService().authStateStream,
        builder: (context, snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.church,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to PCEA Church',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Authentication Status: ${snapshot.data == true ? "Logged In" : "Not Logged In"}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'This is your home screen.\nStart building your app features here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Maintenance screen
class MaintenanceScreen extends StatelessWidget {
  final String? message;

  const MaintenanceScreen({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.build,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Under Maintenance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'The app is currently under maintenance. Please try again later.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Update required screen
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.update,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A new version of the app is available. Please update to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Open app store for update
                  // You would implement this with url_launcher
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Not found screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
