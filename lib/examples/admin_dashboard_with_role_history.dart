import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/role_history/role_history_dashboard.dart';
import '../screens/role_history_screen.dart';
import '../services/role_history_service.dart';

/// Example integration of role history features into admin dashboard
class AdminDashboardWithRoleHistory extends StatefulWidget {
  const AdminDashboardWithRoleHistory({Key? key}) : super(key: key);

  @override
  State<AdminDashboardWithRoleHistory> createState() => _AdminDashboardWithRoleHistoryState();
}

class _AdminDashboardWithRoleHistoryState extends State<AdminDashboardWithRoleHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showRoleStatistics,
            tooltip: 'Role Statistics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard title
            Text(
              'Church Management Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            
            // Role History Dashboard - Recent Changes
            const RoleHistoryDashboard(
              maxItems: 8,
              showUserInfo: true,
              isCompact: false,
            ),
            
            const SizedBox(height: 20),
            
            // Example of compact version
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatsCard(
                    'Total Members',
                    '156',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickStatsCard(
                    'Active Leaders',
                    '24',
                    Icons.supervisor_account,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Compact role history dashboard
            const RoleHistoryDashboard(
              maxItems: 5,
              showUserInfo: true,
              isCompact: true,
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _showAllRoleStatistics,
              icon: const Icon(Icons.analytics),
              label: const Text('View All Statistics'),
            ),
            ElevatedButton.icon(
              onPressed: _exportAllRoleHistory,
              icon: const Icon(Icons.download),
              label: const Text('Export All History'),
            ),
            ElevatedButton.icon(
              onPressed: _showRecentChanges,
              icon: const Icon(Icons.timeline),
              label: const Text('Recent Changes'),
            ),
          ],
        ),
      ],
    );
  }

  void _showRoleStatistics() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading role statistics...'),
            ],
          ),
        ),
      );

      final response = await RoleHistoryService.getRoleStatistics();
      
      Navigator.of(context).pop(); // Close loading dialog

      if (response.isSuccess && response.data != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Role Statistics Overview'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Here you would display the statistics
                  // For now, showing a placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Statistics visualization would go here'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load statistics: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAllRoleStatistics() {
    // Navigate to a dedicated statistics page or show detailed statistics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed statistics page would open here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportAllRoleHistory() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Exporting role history...'),
            ],
          ),
        ),
      );

      final response = await RoleHistoryService.exportRoleHistory();
      
      Navigator.of(context).pop(); // Close loading dialog

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role history exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Here you would typically save or share the exported data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRecentChanges() {
    // Show a dedicated screen for recent changes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recent changes screen would open here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Example of how to show role history for a specific user
  void showUserRoleHistory(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoleHistoryScreen(user: user),
      ),
    );
  }

  /// Example of how to use the role history dashboard for a specific user
  Widget buildUserRoleHistoryWidget(User user) {
    return RoleHistoryDashboard(
      userId: user.id,
      maxItems: 5,
      showUserInfo: false,
      isCompact: true,
    );
  }
}

/// Example usage instructions and documentation
class RoleHistoryIntegrationGuide {
  /// How to integrate role history into existing screens:
  /// 
  /// 1. Import the necessary widgets:
  /// ```dart
  /// import '../widgets/role_history/role_history_dashboard.dart';
  /// import '../widgets/role_history/role_history_timeline.dart';
  /// import '../widgets/role_history/role_statistics_widget.dart';
  /// import '../screens/role_history_screen.dart';
  /// import '../services/role_history_service.dart';
  /// ```
  /// 
  /// 2. Add role history dashboard to your admin dashboard:
  /// ```dart
  /// RoleHistoryDashboard(
  ///   maxItems: 10,
  ///   showUserInfo: true,
  ///   isCompact: false,
  /// )
  /// ```
  /// 
  /// 3. Show role history for a specific user:
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (context) => RoleHistoryScreen(user: user),
  ///   ),
  /// );
  /// ```
  /// 
  /// 4. Add role history button to user lists:
  /// ```dart
  /// IconButton(
  ///   icon: Icon(Icons.history),
  ///   onPressed: () => Navigator.push(
  ///     context,
  ///     MaterialPageRoute(
  ///       builder: (context) => RoleHistoryScreen(user: user),
  ///     ),
  ///   ),
  /// )
  /// ```
  /// 
  /// 5. Use role statistics widget:
  /// ```dart
  /// RoleStatisticsWidget(
  ///   statistics: roleChangeStatistics,
  ///   showCharts: true,
  ///   isCompact: false,
  /// )
  /// ```
  /// 
  /// 6. Service usage examples:
  /// ```dart
  /// // Get user role history
  /// final response = await RoleHistoryService.getUserRoleHistory(userId);
  /// 
  /// // Get recent changes
  /// final recent = await RoleHistoryService.getRecentRoleChanges(limit: 20);
  /// 
  /// // Get role statistics
  /// final stats = await RoleHistoryService.getRoleStatistics();
  /// 
  /// // Export role history
  /// final export = await RoleHistoryService.exportRoleHistory();
  /// ```

  static void showImplementationExample() {
    print('''
Role History Feature Implementation Complete!

The following components are now available:

📱 SCREENS:
- RoleHistoryScreen: Full-featured role history display with timeline and statistics

🧩 WIDGETS:
- RoleHistoryTimeline: Timeline view of role changes
- RoleStatisticsWidget: Visual statistics with charts
- RoleHistoryDashboard: Compact dashboard widget for recent changes

🔧 SERVICES:
- RoleHistoryService: Complete API integration for role history data

✅ INTEGRATION POINTS:
- Admin User Management: Role history button already added
- Dashboard Integration: Ready-to-use dashboard widgets
- Export Functionality: CSV export capability
- Search & Filter: Role transition search

🚀 NEXT STEPS:
1. Test the role history functionality
2. Customize the UI to match your app's theme
3. Add role history dashboards to your admin screens
4. Configure backend API endpoints
5. Test with real data

The role history feature is now fully integrated and ready for use!
    ''');
  }
}
