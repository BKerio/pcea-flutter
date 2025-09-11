import 'package:flutter/material.dart';
import '../../services/role_management_service.dart';

class RoleSelectionWidget extends StatefulWidget {
  final String currentRole;
  final Function(String) onRoleChanged;
  final List<Role> availableRoles;
  final bool enabled;
  
  const RoleSelectionWidget({
    Key? key,
    required this.currentRole,
    required this.onRoleChanged,
    required this.availableRoles,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<RoleSelectionWidget> createState() => _RoleSelectionWidgetState();
}

class _RoleSelectionWidgetState extends State<RoleSelectionWidget> {
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: widget.availableRoles.map<DropdownMenuItem<String>>((role) {
            return DropdownMenuItem<String>(
              value: role.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${role.label} (Level ${role.level})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: widget.enabled ? (String? newValue) {
            setState(() {
              selectedRole = newValue;
            });
            if (newValue != null) {
              widget.onRoleChanged(newValue);
            }
          } : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a role';
            }
            return null;
          },
        ),
        if (selectedRole != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getRoleColor(selectedRole!).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getRoleColor(selectedRole!).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRoleIcon(selectedRole!),
                  size: 16,
                  color: _getRoleColor(selectedRole!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getRoleDescription(selectedRole!),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRoleColor(selectedRole!),
                    ),
                  ),
                ),
              ],
            ),
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

  String _getRoleDescription(String role) {
    final roleObj = widget.availableRoles.firstWhere(
      (r) => r.value == role,
      orElse: () => Role(
        value: role,
        label: role,
        level: 1,
        description: 'Basic member access',
      ),
    );
    return roleObj.description;
  }
}
