import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/app_config_service.dart';

/// API Test Screen to verify backend connection
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  bool _isLoading = false;
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  /// Run API tests
  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    // Test 1: Health Check
    await _testHealthCheck();
    
    // Test 2: App Configuration
    await _testAppConfig();
    
    // Test 3: Server Time
    await _testServerTime();

    setState(() {
      _isLoading = false;
    });
  }

  /// Test health check endpoint
  Future<void> _testHealthCheck() async {
    try {
      final response = await ApiService.healthCheck();
      if (response.isSuccess) {
        _addResult('✅ Health Check: ${response.message}');
      } else {
        _addResult('❌ Health Check: ${response.message}');
      }
    } catch (e) {
      _addResult('❌ Health Check Error: ${e.toString()}');
    }
  }

  /// Test app configuration endpoint
  Future<void> _testAppConfig() async {
    try {
      final configService = AppConfigService();
      final config = await configService.getConfig();
      if (config != null) {
        _addResult('✅ App Config: ${config.appName} v${config.appVersion}');
      } else {
        _addResult('❌ App Config: Failed to load configuration');
      }
    } catch (e) {
      _addResult('❌ App Config Error: ${e.toString()}');
    }
  }

  /// Test server time endpoint
  Future<void> _testServerTime() async {
    try {
      final response = await ApiService.getServerTime();
      if (response.isSuccess && response.data != null) {
        final serverTime = response.data['server_time'];
        _addResult('✅ Server Time: $serverTime');
      } else {
        _addResult('❌ Server Time: ${response.message}');
      }
    } catch (e) {
      _addResult('❌ Server Time Error: ${e.toString()}');
    }
  }

  /// Add result to the list
  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _runTests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Testing connection to Laravel backend...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Running API tests...'),
              ),
            ],

            // Test results
            if (_testResults.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final result = _testResults[index];
                    final isSuccess = result.startsWith('✅');
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          result.substring(2), // Remove emoji
                          style: TextStyle(
                            color: isSuccess ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Instructions
            const Divider(),
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Make sure your Laravel server is running:\n'
              '   php artisan serve --host=127.0.0.1 --port=8080\n\n'
              '2. Check that all endpoints return ✅ (green checkmarks)\n\n'
              '3. If tests fail, verify:\n'
              '   - Laravel server is running\n'
              '   - API routes are configured\n'
              '   - Network permissions are set\n'
              '   - API URLs are correct',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
