import 'dart:async';
import 'api_service.dart';

/// App configuration and network utility service
class AppConfigService {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  // Configuration data
  Map<String, dynamic>? _config;
  DateTime? _lastConfigUpdate;

  // Configuration cache duration (30 minutes)
  static const Duration _cacheTimeout = Duration(minutes: 30);

  /// Get app configuration
  Future<AppConfig?> getConfig({bool forceRefresh = false}) async {
    try {
      // Check if we need to refresh config
      if (forceRefresh || _shouldRefreshConfig()) {
        final response = await ApiService.getAppConfig();
        
        if (response.isSuccess && response.data != null) {
          _config = response.data;
          _lastConfigUpdate = DateTime.now();
        }
      }

      if (_config != null) {
        return AppConfig.fromJson(_config!);
      }
      
      return null;
    } catch (e) {
      print('Failed to get app config: $e');
      return null;
    }
  }

  /// Check if app is in maintenance mode
  Future<bool> isMaintenanceMode() async {
    final config = await getConfig();
    return config?.maintenanceMode ?? false;
  }

  /// Get maintenance message
  Future<String?> getMaintenanceMessage() async {
    final config = await getConfig();
    return config?.maintenanceMessage;
  }

  /// Check if force update is required
  Future<bool> isForceUpdateRequired(String currentVersion) async {
    final config = await getConfig();
    if (config?.forceUpdate == true) {
      return _isVersionOlder(currentVersion, config?.minVersion ?? '');
    }
    return false;
  }

  /// Check API connection
  Future<bool> checkConnection() async {
    try {
      final response = await ApiService.healthCheck();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Get server time
  Future<DateTime?> getServerTime() async {
    try {
      final response = await ApiService.getServerTime();
      if (response.isSuccess && response.data != null) {
        return DateTime.parse(response.data['server_time']);
      }
      return null;
    } catch (e) {
      print('Failed to get server time: $e');
      return null;
    }
  }

  /// Check if configuration should be refreshed
  bool _shouldRefreshConfig() {
    if (_config == null || _lastConfigUpdate == null) return true;
    return DateTime.now().difference(_lastConfigUpdate!) > _cacheTimeout;
  }

  /// Compare version strings (simplified)
  bool _isVersionOlder(String current, String minimum) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final minimumParts = minimum.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final minimumPart = i < minimumParts.length ? minimumParts[i] : 0;
        
        if (currentPart < minimumPart) return true;
        if (currentPart > minimumPart) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      return false; // If parsing fails, assume no update needed
    }
  }
}

/// App configuration model
class AppConfig {
  final String appName;
  final String appVersion;
  final String apiVersion;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final bool forceUpdate;
  final String? minVersion;
  final String? latestVersion;
  final String? welcomeMessage;
  final String? termsUrl;
  final String? privacyUrl;

  AppConfig({
    required this.appName,
    required this.appVersion,
    required this.apiVersion,
    required this.maintenanceMode,
    this.maintenanceMessage,
    required this.forceUpdate,
    this.minVersion,
    this.latestVersion,
    this.welcomeMessage,
    this.termsUrl,
    this.privacyUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['app_name'] ?? 'PCEA App',
      appVersion: json['app_version'] ?? '1.0.0',
      apiVersion: json['api_version'] ?? 'v1',
      maintenanceMode: json['maintenance_mode'] ?? false,
      maintenanceMessage: json['maintenance_message'],
      forceUpdate: json['force_update'] ?? false,
      minVersion: json['min_version'],
      latestVersion: json['latest_version'],
      welcomeMessage: json['welcome_message'],
      termsUrl: json['terms_url'],
      privacyUrl: json['privacy_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'api_version': apiVersion,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
      'force_update': forceUpdate,
      'min_version': minVersion,
      'latest_version': latestVersion,
      'welcome_message': welcomeMessage,
      'terms_url': termsUrl,
      'privacy_url': privacyUrl,
    };
  }

  @override
  String toString() {
    return 'AppConfig{appName: $appName, version: $appVersion, maintenance: $maintenanceMode}';
  }
}
