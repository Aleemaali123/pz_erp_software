import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pz_erp_software/model/employee_model.dart';
import 'package:pz_erp_software/screens/Employee%20List%20Page.dart';
import 'package:pz_erp_software/screens/add_edit_employee.dart';
import 'package:pz_erp_software/screens/employee_detail_screen.dart';
import 'package:pz_erp_software/services/employee_services.dart';
import 'package:pz_erp_software/widget/side_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int totalEmployees = 0;
  late Future<List<EmployeeModel>> _allEmployees;

  Map<String, int> employeeStats = {
    'total': 0,
    'active': 0,
    'inactive': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchTotalEmployees();
    loadEmployeeStats();
    _allEmployees = EmployeeService().getAllEmployees();
  }

  Future<int> getTotalEmployees() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('employees').get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> fetchEmployeeStats() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    int total = snapshot.docs.length;
    int active = 0;
    int inactive = 0;

    for (var doc in snapshot.docs) {
      String status = doc['status']?.toString().toLowerCase() ?? '';
      if (status == 'active') {
        active++;
      } else {
        inactive++;
      }
    }

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
    };
  }

  void loadEmployeeStats() async {
    final stats = await fetchEmployeeStats();
    setState(() {
      employeeStats = stats;
    });
  }

  void fetchTotalEmployees() async {
    int count = await getTotalEmployees();
    setState(() {
      totalEmployees = count;
    });
  }

  void addEmployee() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddEmployeeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: _selectedIndex,
            onMenuSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildDashboardContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEmployee,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Admin 👋',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeListScreen()));
              },
                child: _buildStatCard("Total Employees", "$totalEmployees", Icons.people)),
            const SizedBox(width: 16),
            _buildStatCard("Active", "${employeeStats['active']}", Icons.check_circle, color: Colors.green),
            const SizedBox(width: 16),
            _buildStatCard("Inactive", "${employeeStats['inactive']}", Icons.cancel, color: Colors.red),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          "Employees",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<EmployeeModel>>(
            future: _allEmployees,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No employees found."));
              }

              final employees = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  return _buildEmployeeProfileCard(employees[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeProfileCard(EmployeeModel employee) {
    bool isInactive = employee.status.toLowerCase() != 'active';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(employeeId: employee.employeeId),
          ),
        );
      },
      child: Container(
        width: 140,
        //height: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          //border: Border.all(color: isInactive ? Colors.red : Colors.transparent, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: employee.imageUrl.isNotEmpty
                    ? Image.network(
                  employee.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                )
                    : Image.asset('assets/logo.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              employee.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              employee.designation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[900]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isInactive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Inactive",
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = Colors.blue}) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
