import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/role_management_service.dart';

class BulkRoleAssignmentDialog extends StatefulWidget {
  final List<User> users;
  final List<Role> availableRoles;
  
  const BulkRoleAssignmentDialog({
    Key? key,
    required this.users,
    required this.availableRoles,
  }) : super(key: key);

  @override
  State<BulkRoleAssignmentDialog> createState() => _BulkRoleAssignmentDialogState();
}

class _BulkRoleAssignmentDialogState extends State<BulkRoleAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final Map<int, bool> _selectedUsers = {};
  final Map<int, String> _userRoleAssignments = {};
  bool _isLoading = false;
  String? _defaultRole;

  @override
  void initState() {
    super.initState();
    // Initialize selection state - all users unselected initially
    for (final user in widget.users) {
      _selectedUsers[user.id] = false;
      _userRoleAssignments[user.id] = user.role; // Default to current role
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedUsers.values.where((selected) => selected).length;
    
    return AlertDialog(
      title: const Text('Bulk Role Assignment'),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$selectedCount of ${widget.users.length} users selected',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    if (selectedCount == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Select users below to assign roles in bulk',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Quick actions
              Row(
                children: [
                  Tooltip(
                    message: 'Select all users in the current list',
                    child: ElevatedButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.select_all, size: 16),
                      label: const Text('Select All'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Deselect all users',
                    child: ElevatedButton.icon(
                      onPressed: _selectNone,
                      icon: const Icon(Icons.deselect, size: 16),
                      label: const Text('Select None'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Default role selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Assign Role to Selected Users:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _defaultRole,
                            hint: const Text('Select role to assign'),
                            onChanged: (value) {
                              setState(() {
                                _defaultRole = value;
                              });
                            },
                            items: widget.availableRoles.map((role) {
                              return DropdownMenuItem(
                                value: role.value,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getRoleIcon(role.value),
                                      size: 16,
                                      color: _getRoleColor(role.value),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(role.label),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _defaultRole != null ? _applyRoleToSelected : null,
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                    if (_defaultRole == 'admin')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Warning: Admin role grants full system access',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Users list
              const Text(
                'Select users and assign individual roles:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: widget.users.length,
                    itemBuilder: (context, index) {
                      final user = widget.users[index];
                      final isSelected = _selectedUsers[user.id] ?? false;
                      final assignedRole = _userRoleAssignments[user.id] ?? user.role;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : null,
                          border: index > 0 ? Border(
                            top: BorderSide(color: Colors.grey[200]!)
                          ) : null,
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              _selectedUsers[user.id] = value ?? false;
                            });
                          },
                          title: Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
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
                                  Icon(
                                    _getRoleIcon(user.role),
                                    size: 14,
                                    color: _getRoleColor(user.role),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Current: ${user.roleDisplay}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (assignedRole != user.role) ...[
                                    Icon(
                                      Icons.arrow_right,
                                      size: 14,
                                      color: Colors.orange[700],
                                    ),
                                    Icon(
                                      _getRoleIcon(assignedRole),
                                      size: 14,
                                      color: _getRoleColor(assignedRole),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        _getRoleDisplayName(assignedRole),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          secondary: isSelected
                              ? SizedBox(
                                  width: 120,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: assignedRole,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _userRoleAssignments[user.id] = value;
                                        });
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      isDense: true,
                                    ),
                                    items: widget.availableRoles.map((role) {
                                      return DropdownMenuItem(
                                        value: role.value,
                                        child: Text(
                                          role.label,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : null,
                          isThreeLine: true,
                          dense: true,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Reason field
              TextFormField(
                controller: _reasonController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Why are these roles being assigned?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || selectedCount == 0 ? null : _bulkAssignRoles,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Assign Roles ($selectedCount)'),
        ),
      ],
    );
  }

  void _selectAll() {
    setState(() {
      for (final user in widget.users) {
        _selectedUsers[user.id] = true;
      }
    });
  }

  void _selectNone() {
    setState(() {
      for (final user in widget.users) {
        _selectedUsers[user.id] = false;
      }
    });
  }

  void _applyRoleToSelected() {
    if (_defaultRole == null) return;
    
    setState(() {
      for (final entry in _selectedUsers.entries) {
        if (entry.value) { // If user is selected
          _userRoleAssignments[entry.key] = _defaultRole!;
        }
      }
    });
  }

  void _bulkAssignRoles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Build list of role assignments for selected users
      final assignments = <Map<String, dynamic>>[];
      
      for (final entry in _selectedUsers.entries) {
        if (entry.value) { // If user is selected
          final userId = entry.key;
          final newRole = _userRoleAssignments[userId];
          final user = widget.users.firstWhere((u) => u.id == userId);
          
          // Only include if role is actually changing
          if (newRole != null && newRole != user.role) {
            assignments.add({
              'user_id': userId,
              'role': newRole,
            });
          }
        }
      }

      if (assignments.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No role changes to apply'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final result = await RoleManagementService.bulkAssignRoles(
        assignments,
        reason: _reasonController.text.trim().isNotEmpty 
            ? _reasonController.text.trim()
            : null,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Create updated user objects for successful assignments
          final updatedUsers = <User>[];
          final resultData = result.data;
          
          if (resultData != null && resultData['successful_assignments'] is List) {
            final successfulAssignments = resultData['successful_assignments'] as List;
            
            for (final assignment in successfulAssignments) {
              final userId = assignment['user_id'] as int;
              final newRole = assignment['new_role'] as String;
              final user = widget.users.firstWhere((u) => u.id == userId);
              
              final updatedUser = User(
                id: user.id,
                name: user.name,
                email: user.email,
                role: newRole,
                roleDisplay: _getRoleDisplayName(newRole),
                dashboardRoute: _getDashboardRoute(newRole),
                emailVerifiedAt: user.emailVerifiedAt,
                createdAt: user.createdAt,
                updatedAt: DateTime.now(),
              );
              
              updatedUsers.add(updatedUser);
            }
          }
          
          Navigator.pop(context, updatedUsers);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  String _getDashboardRoute(String role) {
    switch (role) {
      case 'admin':
        return '/admin/dashboard';
      case 'chair':
        return '/chair/dashboard';
      case 'pastor':
        return '/pastor/dashboard';
      case 'church_elder':
        return '/elder/dashboard';
      case 'deacon':
        return '/deacon/dashboard';
      case 'group_leader':
        return '/leader/dashboard';
      case 'member':
        return '/member/dashboard';
      default:
        return '/member/dashboard';
    }
  }
}
