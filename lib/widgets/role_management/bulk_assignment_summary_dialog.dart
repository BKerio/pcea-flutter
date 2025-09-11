import 'package:flutter/material.dart';
import '../../models/user.dart';

class BulkAssignmentSummaryDialog extends StatelessWidget {
  final List<User> updatedUsers;
  final Map<int, String> previousRoles;
  
  const BulkAssignmentSummaryDialog({
    Key? key,
    required this.updatedUsers,
    required this.previousRoles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Bulk Assignment Complete'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Successfully updated ${updatedUsers.length} user role(s)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Changes list
            const Text(
              'Role Changes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: updatedUsers.length,
                itemBuilder: (context, index) {
                  final user = updatedUsers[index];
                  final previousRole = previousRoles[user.id] ?? 'unknown';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user.role),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Previous role
                              Icon(
                                _getRoleIcon(previousRole),
                                size: 14,
                                color: _getRoleColor(previousRole),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getRoleDisplayName(previousRole),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              
                              // Arrow
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_right,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              
                              // New role
                              Icon(
                                _getRoleIcon(user.role),
                                size: 14,
                                color: _getRoleColor(user.role),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.roleDisplay,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'chair':
        return Colors.purple;
      case 'pastor':
        return Colors.blue;
      case 'church_elder':
        return Colors.green;
      case 'deacon':
        return Colors.orange;
      case 'group_leader':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'chair':
        return Icons.business_center;
      case 'pastor':
        return Icons.church;
      case 'church_elder':
        return Icons.psychology;
      case 'deacon':
        return Icons.room_service;
      case 'group_leader':
        return Icons.groups;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'chair':
        return 'Church Chair';
      case 'pastor':
        return 'Pastor';
      case 'church_elder':
        return 'Church Elder';
      case 'deacon':
        return 'Deacon';
      case 'group_leader':
        return 'Group Leader';
      case 'member':
        return 'Member';
      default:
        return role.replaceAll('_', ' ').split(' ').map((word) => 
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }
}
