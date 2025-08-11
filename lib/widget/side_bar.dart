import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_wrapper.dart';
import '../auth/login_screen.dart';
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
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get();
      setState(() {
        adminName = doc.data()?['name'] ?? 'Admin';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );

    if (shouldLogout == true) {
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              (route) => false, // Removes all previous routes
        );
      }
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
          const SizedBox(height: 20),
          // Logo
          Container(
            width: double.infinity,
            height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pet.png"),
                fit: BoxFit.cover,
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
                  backgroundImage: AssetImage('assets/WhatsApp Image 2025-08-08 at 15.42.17_fbde6885.jpg'),
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
                        adminName ?? "Aleema",
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
                _buildMenuItem(
                    index: 0, icon: Icons.dashboard, label: "Dashboard"),
                _buildMenuItem(
                    index: 1,
                    icon: Icons.supervisor_account,
                    label: "Admin Users"),
                _buildMenuItem(
                    index: 2, icon: Icons.people, label: "Employees"),
                _buildMenuItem(
                    index: 3, icon: Icons.settings, label: "Settings"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 🔽 Add this logout section at the bottom
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Divider(color: Colors.white24),
                InkWell(
                  onTap: () {
                    _logout(context);
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
