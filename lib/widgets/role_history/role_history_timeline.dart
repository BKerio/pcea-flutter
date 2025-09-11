import 'package:flutter/material.dart';
import '../../models/role_change.dart';

/// A timeline widget that displays role change history
class RoleHistoryTimeline extends StatelessWidget {
  final List<RoleChange> roleChanges;
  final bool showFullDetails;
  final bool isCompact;

  const RoleHistoryTimeline({
    Key? key,
    required this.roleChanges,
    this.showFullDetails = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (roleChanges.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: isCompact ? const NeverScrollableScrollPhysics() : null,
      itemCount: roleChanges.length,
      itemBuilder: (context, index) {
        final change = roleChanges[index];
        final isLast = index == roleChanges.length - 1;
        
        return _buildTimelineItem(context, change, isLast);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No role changes found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This user has not had any role changes yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, RoleChange change, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getChangeColor(change),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getChangeColor(change).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: isLast ? 0 : 16,
              ),
              child: _buildChangeCard(context, change),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCard(BuildContext context, RoleChange change) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role change header
            Row(
              children: [
                Icon(
                  _getChangeIcon(change),
                  color: _getChangeColor(change),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: change.fromRoleDisplay,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: ' → ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: change.toRoleDisplay,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getChangeColor(change),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (change.wasPromotion)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.trending_up, size: 12, color: Colors.green),
                        SizedBox(width: 2),
                        Text(
                          'Promotion',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            if (showFullDetails) ...[
              const SizedBox(height: 12),
              
              // Changed by information
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Changed by: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    change.changedBy.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Reason (if provided)
              if (change.reason != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reason: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        change.reason!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change.changedAtHuman,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (change.hierarchyChange != 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getChangeColor(change).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${change.hierarchyChange > 0 ? '+' : ''}${change.hierarchyChange}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getChangeColor(change),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                change.changedAtHuman,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
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
