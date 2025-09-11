import 'package:flutter/material.dart';
import '../../models/role_change.dart';

/// A widget that displays role change statistics with visual charts
class RoleStatisticsWidget extends StatelessWidget {
  final RoleChangeStatistics statistics;
  final bool showCharts;
  final bool isCompact;

  const RoleStatisticsWidget({
    Key? key,
    required this.statistics,
    this.showCharts = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCompact) ...[
            Text(
              'Role Change Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Statistics grid
          _buildStatisticsGrid(context),
          
          if (showCharts && !isCompact) ...[
            const SizedBox(height: 24),
            _buildChart(context),
          ],
          
          if (statistics.firstRoleAssignment != null || statistics.lastRoleChange != null) ...[
            const SizedBox(height: 16),
            _buildTimestamps(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final stats = [
      _StatItem(
        title: 'Total Changes',
        value: statistics.totalChanges.toString(),
        icon: Icons.history,
        color: Colors.blue,
      ),
      _StatItem(
        title: 'Promotions',
        value: statistics.promotions.toString(),
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      _StatItem(
        title: 'Demotions',
        value: statistics.demotions.toString(),
        icon: Icons.trending_down,
        color: Colors.orange,
      ),
      _StatItem(
        title: 'Lateral Moves',
        value: statistics.lateralMoves.toString(),
        icon: Icons.trending_flat,
        color: Colors.grey,
      ),
    ];

    return GridView.count(
      crossAxisCount: isCompact ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isCompact ? 1.2 : 1.0,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: stats.map((stat) => _buildStatCard(context, stat)).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, _StatItem stat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: isCompact ? 20 : 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: TextStyle(
                fontSize: isCompact ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: stat.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 11 : 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (statistics.totalChanges == 0) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Distribution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildProgressBars(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildPercentageDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    final total = statistics.totalChanges;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        if (statistics.promotions > 0)
          Expanded(
            child: _buildProgressBar(
              'Promotions',
              statistics.promotions / total,
              Colors.green,
            ),
          ),
        if (statistics.demotions > 0)
          Expanded(
            child: _buildProgressBar(
              'Demotions',
              statistics.demotions / total,
              Colors.orange,
            ),
          ),
        if (statistics.lateralMoves > 0)
          Expanded(
            child: _buildProgressBar(
              'Lateral',
              statistics.lateralMoves / total,
              Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageDisplay() {
    final total = statistics.totalChanges;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (statistics.promotions > 0)
          _buildPercentageChip(
            '${((statistics.promotions / total) * 100).round()}%',
            Colors.green,
          ),
        if (statistics.demotions > 0)
          _buildPercentageChip(
            '${((statistics.demotions / total) * 100).round()}%',
            Colors.orange,
          ),
        if (statistics.lateralMoves > 0)
          _buildPercentageChip(
            '${((statistics.lateralMoves / total) * 100).round()}%',
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildPercentageChip(String percentage, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        percentage,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTimestamps(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statistics.firstRoleAssignment != null)
            _buildTimestampRow(
              Icons.flag,
              'First Role Assignment',
              _formatDate(statistics.firstRoleAssignment!),
              Colors.blue,
            ),
          if (statistics.firstRoleAssignment != null && statistics.lastRoleChange != null)
            const SizedBox(height: 8),
          if (statistics.lastRoleChange != null)
            _buildTimestampRow(
              Icons.schedule,
              'Last Role Change',
              _formatDate(statistics.lastRoleChange!),
              Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildTimestampRow(IconData icon, String label, String date, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks} week${weeks > 1 ? 's' : ''} ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    }
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
