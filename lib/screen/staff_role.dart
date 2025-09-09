import 'package:flutter/material.dart';

class TreasurerScreen extends StatelessWidget {
  const TreasurerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treasurer Dashboard")),
      body: const Center(child: Text("Welcome, Treasurer!")),
    );
  }
}

class ElderScreen extends StatelessWidget {
  const ElderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Elder Dashboard")),
      body: const Center(child: Text("Welcome, Elder!")),
    );
  }
}

class DeaconScreen extends StatelessWidget {
  const DeaconScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deacon Dashboard")),
      body: const Center(child: Text("Welcome, Deacon!")),
    );
  }
}

class GroupLeaderScreen extends StatelessWidget {
  const GroupLeaderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Leader Dashboard")),
      body: const Center(child: Text("Welcome, Group Leader!")),
    );
  }
}

class ChairmanScreen extends StatelessWidget {
  const ChairmanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chairman Dashboard")),
      body: const Center(child: Text("Welcome, Chairman!")),
    );
  }
}

class SecretaryScreen extends StatelessWidget {
  const SecretaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secretary Dashboard")),
      body: const Center(child: Text("Welcome, Secretary!")),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 242, 243),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'PCEA Church Staff Portal',
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
                  DashboardCard(
                    icon: Icons.security,
                    title: 'Treasurer',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TreasurerScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.group,
                    title: 'Elder',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ElderScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.leaderboard,
                    title: 'Deacon',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeaconScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.attach_money,
                    title: 'Group Leader',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupLeaderScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.people_alt,
                    title: 'Chairman',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChairmanScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.support_agent,
                    title: 'Secretary',
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecretaryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
