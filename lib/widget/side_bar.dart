import 'package:flutter/material.dart';
import 'package:pz_erp_software/screens/Employee%20List%20Page.dart';
import '../theme/color_theme.dart';

class SideNavigation extends StatelessWidget {
  final Function(int) onMenuSelected;
  final int selectedIndex;

  const SideNavigation({
    super.key,
    required this.onMenuSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
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

          // Divider line
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
                  //backgroundColor: Colors.yellow,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome,",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Divider line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.white24),
          ),

          const SizedBox(height: 8),

          // Menu Items
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(index: 0, icon: Icons.dashboard, label: "Dashboard"),
                _buildMenuItem(index: 1, icon: Icons.supervisor_account, label: "Admin Users"),

                // Static item for Employees
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.white70),
                  title: const Text(
                    "Employees",
                    style: TextStyle(color: Colors.white),
                  ),
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

          // Bottom Padding
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
    final isSelected = selectedIndex == index;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(
        icon,
        color: isSelected ? Colors.amber : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.amber : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.black26,
      onTap: () => onMenuSelected(index),
    );
  }
}
