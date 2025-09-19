import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/member_service.dart';
import '../models/user.dart';
import '../models/member.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({Key? key}) : super(key: key);

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final AuthService _authService = AuthService();
  final MemberService _memberService = MemberService();
  User? _currentUser;
  Member? _currentMember;
  List<Dependent> _dependents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _currentUser = _authService.currentUser;
      _isLoading = true;
    });

    try {
      // Load member profile
      final memberResult = await _memberService.getProfile();
      if (memberResult.success && memberResult.member != null) {
        setState(() {
          _currentMember = memberResult.member;
        });
      }

      // Load dependents
      final dependentsResult = await _memberService.getDependents();
      if (dependentsResult.success && dependentsResult.dependents != null) {
        setState(() {
          _dependents = dependentsResult.dependents!;
        });
      }
    } catch (e) {
      print('Error loading member data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 242, 243),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              _currentUser?.name ?? 'Member',
              style: const TextStyle(
                color: Color(0xFF35C2C1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Member Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF35C2C1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                    icon: Icons.person,
                    title: 'My Profile',
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile feature coming soon!')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.event,
                    title: 'Events',
                    color: Colors.green,
                    onTap: () {
                      // Navigate to events screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Events feature coming soon!')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.family_restroom,
                    title: 'My Dependents',
                    color: Colors.indigo,
                    onTap: _showDependentsDialog,
                    subtitle: '${_dependents.length} dependent${_dependents.length != 1 ? 's' : ''}',
                  ),
                  _buildDashboardCard(
                    icon: Icons.library_books,
                    title: 'Resources',
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to resources screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resources feature coming soon!')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.payment,
                    title: 'Offerings',
                    color: Colors.teal,
                    onTap: () {
                      // Navigate to offerings screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offerings feature coming soon!')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.message,
                    title: 'Messages',
                    color: Colors.red,
                    onTap: () {
                      // Navigate to messages screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Messages feature coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // User Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Name', _currentUser?.name ?? 'Not Available'),
                  _buildInfoRow('Email', _currentUser?.email ?? 'Not Available'),
                  _buildInfoRow('Role', _currentUser?.roleDisplay ?? 'Member'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dependents management dialog
  void _showDependentsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Dependents',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF35C2C1),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              
              // Add dependent button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_dependents.length} dependent${_dependents.length != 1 ? 's' : ''} registered',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addDependent,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Dependent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35C2C1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dependents list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _dependents.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.family_restroom,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No dependents registered',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add your dependents to manage their information',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _dependents.length,
                            itemBuilder: (context, index) {
                              final dependent = _dependents[index];
                              return _buildDependentCard(dependent, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build dependent card widget
  Widget _buildDependentCard(Dependent dependent, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF35C2C1),
          child: Text(
            dependent.name.isNotEmpty ? dependent.name[0].toUpperCase() : 'D',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          dependent.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Born: ${dependent.yearOfBirth} • Age: ${dependent.age}'),
            if (dependent.school != null && dependent.school!.isNotEmpty)
              Text('School: ${dependent.school}'),
            Row(
              children: [
                if (dependent.isBaptized)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Baptized',
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                if (dependent.isBaptized && dependent.takesHolyCommunion)
                  const SizedBox(width: 4),
                if (dependent.takesHolyCommunion)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Holy Communion',
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editDependent(dependent, index);
            } else if (value == 'delete') {
              _deleteDependent(dependent, index);
            }
          },
        ),
      ),
    );
  }

  /// Add new dependent
  void _addDependent() {
    Navigator.of(context).pop(); // Close the dependents dialog first
    _showDependentFormDialog();
  }

  /// Edit existing dependent
  void _editDependent(Dependent dependent, int index) {
    Navigator.of(context).pop(); // Close the dependents dialog first
    _showDependentFormDialog(dependent: dependent, index: index);
  }

  /// Delete dependent with confirmation
  void _deleteDependent(Dependent dependent, int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dependent'),
        content: Text('Are you sure you want to remove ${dependent.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && dependent.id != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _memberService.deleteDependent(dependent.id!);
        if (result.success) {
          setState(() {
            _dependents.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${dependent.name} has been removed'),
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete dependent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show dependent form dialog (add/edit)
  void _showDependentFormDialog({Dependent? dependent, int? index}) {
    final nameController = TextEditingController(text: dependent?.name ?? '');
    final schoolController = TextEditingController(text: dependent?.school ?? '');
    final birthCertController = TextEditingController(text: dependent?.birthCertNumber ?? '');
    int selectedYear = dependent?.yearOfBirth ?? DateTime.now().year;
    bool isBaptized = dependent?.isBaptized ?? false;
    bool takesHolyCommunion = dependent?.takesHolyCommunion ?? false;
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(dependent == null ? 'Add Dependent' : 'Edit Dependent'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Year of Birth
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year of Birth *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        DateTime.now().year - 1900 + 1,
                        (index) => DateTime.now().year - index,
                      ).map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (year) {
                        if (year != null) {
                          setDialogState(() {
                            selectedYear = year;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Birth Certificate Number (Optional)
                    TextFormField(
                      controller: birthCertController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Birth Certificate Number (Optional)',
                        border: OutlineInputBorder(),
                        helperText: 'Must be exactly 9 digits if provided',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length != 9) {
                          return 'Birth certificate number must be exactly 9 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // School (Optional)
                    TextFormField(
                      controller: schoolController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'School (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Baptized checkbox
                    CheckboxListTile(
                      value: isBaptized,
                      title: const Text('Is Baptized'),
                      onChanged: (value) {
                        setDialogState(() {
                          isBaptized = value ?? false;
                        });
                      },
                    ),
                    
                    // Holy Communion checkbox
                    CheckboxListTile(
                      value: takesHolyCommunion,
                      title: const Text('Takes Holy Communion'),
                      onChanged: (value) {
                        setDialogState(() {
                          takesHolyCommunion = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (!formKey.currentState!.validate()) return;
                
                setDialogState(() {
                  isSubmitting = true;
                });
                
                try {
                  final birthCert = birthCertController.text.trim();
                  
                  final newDependent = Dependent(
                    id: dependent?.id,
                    name: nameController.text.trim(),
                    yearOfBirth: selectedYear,
                    birthCertNumber: birthCert.isEmpty ? null : birthCert,
                    school: schoolController.text.trim().isEmpty ? null : schoolController.text.trim(),
                    isBaptized: isBaptized,
                    takesHolyCommunion: takesHolyCommunion,
                  );
                  
                  ServiceResult result;
                  if (dependent == null) {
                    // Add new dependent
                    final addResult = await _memberService.addDependent(newDependent);
                    if (addResult.success && addResult.dependent != null) {
                      setState(() {
                        _dependents.add(addResult.dependent!);
                      });
                      result = ServiceResult.success('Dependent added successfully');
                    } else {
                      result = ServiceResult.failure(addResult.message, addResult.errors);
                    }
                  } else {
                    // Update existing dependent
                    final updateResult = await _memberService.updateDependent(dependent.id!, newDependent);
                    if (updateResult.success && updateResult.dependent != null) {
                      setState(() {
                        _dependents[index!] = updateResult.dependent!;
                      });
                      result = ServiceResult.success('Dependent updated successfully');
                    } else {
                      result = ServiceResult.failure(updateResult.message, updateResult.errors);
                    }
                  }
                  
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success ? Colors.green : Colors.red,
                    ),
                  );
                  
                  // Reopen dependents dialog
                  if (result.success) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _showDependentsDialog();
                    });
                  }
                  
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setDialogState(() {
                    isSubmitting = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35C2C1),
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(dependent == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
