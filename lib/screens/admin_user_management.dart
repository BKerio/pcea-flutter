import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/role_management_service.dart';
import '../services/user_service.dart';
import '../widgets/role_management/role_assignment_dialog.dart';
import '../widgets/role_management/bulk_role_assignment_dialog.dart';
import 'role_history_screen.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({Key? key}) : super(key: key);

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  List<Role> _availableRoles = [];
  bool _isLoading = false;
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load available roles
      print('Loading roles...');
      final rolesResult = await RoleManagementService.getAvailableRoles();
      print('Roles result: ${rolesResult.success}, data: ${rolesResult.data}');
      
      if (rolesResult.isSuccess && rolesResult.data != null) {
        try {
          // Handle different response formats
          if (rolesResult.data is Map && rolesResult.data['roles'] is List) {
            // Backend returns {roles: [...], hierarchy: {...}}
            print('Roles data is nested, extracting roles list...');
            final rolesData = rolesResult.data['roles'] as List;
            _availableRoles = rolesData
                .map((item) => Role.fromJson(item))
                .toList();
            print('Loaded ${_availableRoles.length} roles from nested structure');
          } else if (rolesResult.data is List) {
            // Direct list format
            print('Roles data is a direct list');
            _availableRoles = (rolesResult.data as List)
                .map((item) => Role.fromJson(item))
                .toList();
            print('Loaded ${_availableRoles.length} roles from direct list');
          } else {
            print('Unexpected roles data format: ${rolesResult.data.runtimeType}');
            _availableRoles = [];
          }
        } catch (e) {
          print('Error parsing roles: $e');
          _availableRoles = [];
        }
      } else {
        print('Failed to load roles: ${rolesResult.message}');
        _availableRoles = [];
      }

      // Load users from user service
      print('Loading users...');
      final usersResult = await UserService.getAllUsers();
      print('Users result: ${usersResult.success}, data type: ${usersResult.data.runtimeType}');
      
      if (usersResult.success && usersResult.data != null) {
        try {
          // Handle paginated response (Laravel pagination format)
          if (usersResult.data is Map && usersResult.data['data'] is List) {
            print('Users data is paginated, extracting user list...');
            final usersData = usersResult.data['data'] as List;
            print('Found ${usersData.length} users in pagination');
            
            _users = usersData.map((json) {
              try {
                return User.fromJson(json);
              } catch (e) {
                print('Error parsing user: $e');
                print('User JSON: $json');
                return null;
              }
            }).where((user) => user != null).cast<User>().toList();
            
            print('Successfully parsed ${_users.length} users');
            _filteredUsers = _users;
          } else if (usersResult.data is List) {
            print('Users data is a direct List with ${usersResult.data.length} items');
            _users = (usersResult.data as List)
                .map((json) => User.fromJson(json))
                .toList();
            _filteredUsers = _users;
          } else {
            print('Unexpected data format: ${usersResult.data}');
            _users = [];
            _filteredUsers = [];
          }
        } catch (e) {
          print('Error processing users data: $e');
          _users = [];
          _filteredUsers = [];
        }
      } else {
        _users = [];
        _filteredUsers = [];
        print('Failed to load users: ${usersResult.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load users: ${usersResult.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _loadData: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
        final matchesRole = _selectedRoleFilter == null ||
            user.role == _selectedRoleFilter;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Management'),
            if (_users.isNotEmpty)
              Text(
                '${_filteredUsers.length} of ${_users.length} users',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Role filter
                Row(
                  children: [
                    const Text(
                      'Filter by role:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: _selectedRoleFilter,
                        isExpanded: true,
                        hint: const Text('All roles'),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoleFilter = value;
                          });
                          _filterUsers();
                        },
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All roles'),
                          ),
                          ..._availableRoles.map((role) => DropdownMenuItem(
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
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          return _buildUserCard(_filteredUsers[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _filteredUsers.isEmpty 
          ? null 
          : FloatingActionButton.extended(
              onPressed: _showBulkAssignmentDialog,
              icon: const Icon(Icons.group_add),
              label: Text('Bulk Assign (${_filteredUsers.length})'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _users.isEmpty
                ? 'No users found'
                : 'No users match your search',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _users.isEmpty
                ? 'Users will appear here when available'
                : 'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getRoleIcon(user.role),
                  size: 16,
                  color: _getRoleColor(user.role),
                ),
                const SizedBox(width: 4),
                Text(
                  user.roleDisplay,
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showUserRoleHistory(user),
              tooltip: 'Role History',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showRoleAssignmentDialog(user),
              tooltip: 'Assign Role',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showRoleAssignmentDialog(User user) async {
    if (_availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No roles available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<User>(
      context: context,
      builder: (context) => RoleAssignmentDialog(
        user: user,
        availableRoles: _availableRoles,
      ),
    );

    if (result != null) {
      // Update the user in the list
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        setState(() {
          _users[index] = result;
        });
        _filterUsers();
      }
    }
  }

  void _showUserRoleHistory(User user) async {
    try {
      // Navigate to the role history screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoleHistoryScreen(user: user),
        ),
      );
    } catch (e) {
      print('Error navigating to role history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open role history: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBulkAssignmentDialog() async {
    if (_availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No roles available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No users available for bulk assignment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<List<User>>(
      context: context,
      builder: (context) => BulkRoleAssignmentDialog(
        users: _filteredUsers.isNotEmpty ? _filteredUsers : _users,
        availableRoles: _availableRoles,
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Update the users in the list
      setState(() {
        for (final updatedUser in result) {
          final index = _users.indexWhere((u) => u.id == updatedUser.id);
          if (index != -1) {
            _users[index] = updatedUser;
          }
        }
      });
      _filterUsers();

      // Show summary message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully updated ${result.length} user role(s)'),
          backgroundColor: Colors.green,
        ),
      );
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


}
