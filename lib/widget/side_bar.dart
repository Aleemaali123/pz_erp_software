import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/Employee List Page.dart';
import '../theme/color_theme.dart';

class SideNavigation extends StatefulWidget {
  final Function(int) onMenuSelected;
  final int selectedIndex;

  const SideNavigation({
    super.key,
    required this.onMenuSelected,
    required this.selectedIndex,
  });

  @override
  _SideNavigationState createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  String? adminName;

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  Future<void> fetchAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('admin').doc(user.uid).get();
      setState(() {
        adminName = doc.data()?['name'] ?? 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 240,
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Logo
          Center(
            child: Container(
              width: 140,
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/petzify.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white24),
          ),
          const SizedBox(height: 16),
          // User Profile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/aleeee.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome,",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        adminName ?? "Loading...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white24),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(index: 0, icon: Icons.dashboard, label: "Dashboard"),
                _buildMenuItem(index: 1, icon: Icons.supervisor_account, label: "Admin Users"),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.white70),
                  title: const Text("Employees", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
                    );
                  },
                ),
                _buildMenuItem(index: 3, icon: Icons.settings, label: "Settings"),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.selectedIndex == index;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: isSelected ? Colors.amber : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.amber : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.black26,
      onTap: () => widget.onMenuSelected(index),
    );
  }
}
