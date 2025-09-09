import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/app_config_service.dart';
import '../services/auth_service.dart';

/// Simple test screen to verify API integration
class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({Key? key}) : super(key: key);

  @override
  State<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  bool _isLoading = false;
  final List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _results.clear();
    });

    // Test 1: Health Check
    try {
      final health = await ApiService.healthCheck();
      _addResult('Health Check: ${health.isSuccess ? "✅ Connected" : "❌ Failed"}');
    } catch (e) {
      _addResult('Health Check: ❌ Error - ${e.toString()}');
    }

    // Test 2: App Config
    try {
      final configService = AppConfigService();
      final config = await configService.getConfig();
      _addResult('App Config: ${config != null ? "✅ Loaded" : "❌ Failed"}');
    } catch (e) {
      _addResult('App Config: ❌ Error - ${e.toString()}');
    }

    // Test 3: Auth Service
    try {
      final authService = AuthService();
      _addResult('Auth Service: ✅ Initialized');
      _addResult('Is Authenticated: ${authService.isAuthenticated ? "Yes" : "No"}');
    } catch (e) {
      _addResult('Auth Service: ❌ Error - ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _results.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        actions: [
          IconButton(
            onPressed: _runTests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Testing API Integration...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final isSuccess = result.contains('✅');
                  
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                      title: Text(result),
                    ),
                  );
                },
              ),
            ),

            const Divider(),
            const Text(
              'Next Steps:\n'
              '• Start your Laravel backend server\n'
              '• Test login/register functionality\n'
              '• Verify staff role navigation',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/welcome');
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
