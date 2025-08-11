import 'package:flutter/material.dart';
import 'package:pz_erp_software/home_screen.dart';
import 'package:pz_erp_software/widget/side_bar.dart';
import '../screens/Employee List Page.dart';


class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int selectedIndex = 0;

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return const Center(child: Text("Admin Users Page"));
      case 2:
        return const EmployeeListScreen();
      case 3:
        return const Center(child: Text("Settings Page"));
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          SideNavigation(
            selectedIndex: selectedIndex,
            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }
}
