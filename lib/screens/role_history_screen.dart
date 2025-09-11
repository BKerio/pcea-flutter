import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/role_change.dart';
import '../services/role_history_service.dart';
import '../widgets/role_history/role_history_timeline.dart';
import '../widgets/role_history/role_statistics_widget.dart';

/// Screen to display role history for a specific user
class RoleHistoryScreen extends StatefulWidget {
  final User user;

  const RoleHistoryScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<RoleHistoryScreen> createState() => _RoleHistoryScreenState();
}

class _RoleHistoryScreenState extends State<RoleHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  RoleHistoryResponse? _roleHistoryResponse;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoleHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoleHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMorePages) return;
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final response = await RoleHistoryService.getUserRoleHistory(
        widget.user.id,
        page: loadMore ? _currentPage + 1 : 1,
        perPage: 20,
      );

      if (response.isSuccess && response.data != null) {
        final newData = response.data as RoleHistoryResponse;
        
        setState(() {
          if (loadMore) {
            // Append new history items
            _roleHistoryResponse = RoleHistoryResponse(
              user: newData.user,
              history: [
                ..._roleHistoryResponse!.history,
                ...newData.history,
              ],
              pagination: newData.pagination,
              statistics: newData.statistics,
            );
            _currentPage = newData.pagination.currentPage;
          } else {
            _roleHistoryResponse = newData;
            _currentPage = newData.pagination.currentPage;
          }
          _hasMorePages = newData.pagination.hasMorePages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load role history: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Role History'),
            Text(
              widget.user.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.timeline),
              text: 'Timeline',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Statistics',
            ),
          ],
        ),
        actions: [
          if (_roleHistoryResponse != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportRoleHistory,
              tooltip: 'Export History',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadRoleHistory(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _roleHistoryResponse == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading role history...'),
          ],
        ),
      );
    }

    if (_error != null && _roleHistoryResponse == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Role History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadRoleHistory(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_roleHistoryResponse == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Column(
      children: [
        // User info header
        _buildUserInfoHeader(),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTimelineTab(),
              _buildStatisticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoHeader() {
    final user = _roleHistoryResponse!.user;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Current Role: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        user.roleDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadRoleHistory(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RoleHistoryTimeline(
                    roleChanges: _roleHistoryResponse!.history,
                  ),
                  
                  // Load more button
                  if (_hasMorePages) ...[
                    const SizedBox(height: 16),
                    if (_isLoadingMore)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _loadRoleHistory(loadMore: true),
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Load More'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoleStatisticsWidget(
            statistics: _roleHistoryResponse!.statistics,
            showCharts: true,
          ),
          
          const SizedBox(height: 24),
          
          // Additional insights
          _buildInsightsSection(),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    final stats = _roleHistoryResponse!.statistics;
    final insights = <String>[];

    // Generate insights based on statistics
    if (stats.promotions > stats.demotions) {
      insights.add('📈 Positive career trajectory with more promotions than demotions');
    } else if (stats.demotions > stats.promotions) {
      insights.add('📉 More demotions than promotions in role history');
    }

    if (stats.lateralMoves > 0) {
      insights.add('↔️ Has experience with lateral role changes');
    }

    if (stats.totalChanges == 0) {
      insights.add('🆕 No role changes yet - still in original assigned role');
    } else if (stats.totalChanges > 5) {
      insights.add('🔄 High number of role changes indicates active involvement');
    }

    if (insights.isEmpty) {
      insights.add('✅ Standard role progression pattern');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportRoleHistory() async {
    try {
      // Show loading dialog
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

      final response = await RoleHistoryService.exportRoleHistory(
        userId: widget.user.id,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (response.isSuccess && response.data != null) {
        // Handle successful export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role history exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Here you could save the file or share it
        // For now, we'll just show a success message
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
}
