import 'package:flutter/material.dart';
import '../../models/role_change.dart';
import '../../services/role_history_service.dart';

/// A dashboard widget showing recent role changes
class RoleHistoryDashboard extends StatefulWidget {
  final int? userId; // If null, shows all recent changes
  final int maxItems;
  final bool showUserInfo;
  final bool isCompact;

  const RoleHistoryDashboard({
    Key? key,
    this.userId,
    this.maxItems = 10,
    this.showUserInfo = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<RoleHistoryDashboard> createState() => _RoleHistoryDashboardState();
}

class _RoleHistoryDashboardState extends State<RoleHistoryDashboard> {
  List<RoleChange> _recentChanges = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentChanges();
  }

  Future<void> _loadRecentChanges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.userId != null) {
        // Load changes for specific user
        final response = await RoleHistoryService.getUserRoleHistory(
          widget.userId!,
          page: 1,
          perPage: widget.maxItems,
        );

        if (response.isSuccess && response.data != null) {
          final roleHistoryResponse = response.data as RoleHistoryResponse;
          setState(() {
            _recentChanges = roleHistoryResponse.history;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = response.message;
            _isLoading = false;
          });
        }
      } else {
        // Load recent changes for all users
        final response = await RoleHistoryService.getRecentRoleChanges(
          limit: widget.maxItems,
        );

        if (response.isSuccess && response.data != null) {
          setState(() {
            _recentChanges = (response.data as List).cast<RoleChange>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load recent changes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.history,
          size: widget.isCompact ? 20 : 24,
          color: Colors.blue[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.userId != null 
                ? 'Role History' 
                : 'Recent Role Changes',
            style: TextStyle(
              fontSize: widget.isCompact ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        if (!_isLoading)
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadRecentChanges,
            tooltip: 'Refresh',
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SizedBox(
        height: widget.isCompact ? 100 : 150,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: widget.isCompact ? 100 : 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: widget.isCompact ? 32 : 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading data',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!widget.isCompact) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    if (_recentChanges.isEmpty) {
      return Container(
        height: widget.isCompact ? 100 : 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              color: Colors.grey[400],
              size: widget.isCompact ? 32 : 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No recent changes',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: widget.isCompact ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentChanges
          .map((change) => _buildChangeItem(change))
          .toList(),
    );
  }

  Widget _buildChangeItem(RoleChange change) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isCompact ? 8 : 12,
        horizontal: 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: widget.isCompact ? 8 : 10,
            height: widget.isCompact ? 8 : 10,
            decoration: BoxDecoration(
              color: _getChangeColor(change),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          // Change details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name (if showing multiple users)
                if (widget.showUserInfo && widget.userId == null) ...[
                  Text(
                    change.changedBy.name,
                    style: TextStyle(
                      fontSize: widget.isCompact ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                
                // Role change
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: widget.isCompact ? 11 : 13,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(text: change.fromRoleDisplay),
                      const TextSpan(text: ' → '),
                      TextSpan(
                        text: change.toRoleDisplay,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getChangeColor(change),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Timestamp
                Text(
                  change.changedAtHuman,
                  style: TextStyle(
                    fontSize: widget.isCompact ? 10 : 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Action indicator
          Icon(
            _getChangeIcon(change),
            size: widget.isCompact ? 14 : 16,
            color: _getChangeColor(change),
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(RoleChange change) {
    if (change.wasPromotion) {
      return Colors.green;
    } else if (change.hierarchyChange < 0) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  IconData _getChangeIcon(RoleChange change) {
    if (change.wasPromotion) {
      return Icons.trending_up;
    } else if (change.hierarchyChange < 0) {
      return Icons.trending_down;
    } else {
      return Icons.trending_flat;
    }
  }
}
