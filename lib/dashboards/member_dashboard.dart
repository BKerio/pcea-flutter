import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({Key? key}) : super(key: key);

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _currentUser = _authService.currentUser;
    });
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
                    icon: Icons.group,
                    title: 'My Group',
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to group screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group feature coming soon!')),
                      );
                    },
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
}
