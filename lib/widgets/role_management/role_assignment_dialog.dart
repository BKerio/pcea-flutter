import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/role_management_service.dart';
import 'role_selection_widget.dart';

class RoleAssignmentDialog extends StatefulWidget {
  final User user;
  final List<Role> availableRoles;
  
  const RoleAssignmentDialog({
    Key? key,
    required this.user,
    required this.availableRoles,
  }) : super(key: key);

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Role to ${widget.user.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current role info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(widget.user.role),
                      color: _getRoleColor(widget.user.role),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Role',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.user.roleDisplay,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // User info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Role selection
              RoleSelectionWidget(
                currentRole: widget.user.role,
                availableRoles: widget.availableRoles,
                enabled: !_isLoading,
                onRoleChanged: (role) {
                  setState(() {
                    selectedRole = role;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Reason field
              TextFormField(
                controller: _reasonController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Why is this role being assigned?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  // Reason is optional, so no validation needed
                  return null;
                },
              ),
              
              // Warning for admin role
              if (selectedRole == 'admin')
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: Admin role grants full system access. Only assign to trusted individuals.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
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
          onPressed: _isLoading || selectedRole == widget.user.role 
              ? null 
              : _assignRole,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign Role'),
        ),
      ],
    );
  }

  void _assignRole() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedRole == null || selectedRole == widget.user.role) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a different role'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RoleManagementService.assignRole(
        widget.user.id,
        selectedRole!,
        reason: _reasonController.text.trim().isNotEmpty 
            ? _reasonController.text.trim()
            : null,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Create an updated user object with the new role
          final updatedUser = User(
            id: widget.user.id,
            name: widget.user.name,
            email: widget.user.email,
            role: selectedRole!,
            roleDisplay: _getRoleDisplayName(selectedRole!),
            dashboardRoute: _getDashboardRoute(selectedRole!),
            emailVerifiedAt: widget.user.emailVerifiedAt,
            createdAt: widget.user.createdAt,
            updatedAt: DateTime.now(),
          );
          
          Navigator.pop(context, updatedUser);
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
