import 'package:flutter/material.dart';
import 'package:pz_erp_software/model/employee_model.dart';
import '../services/employee_services.dart';
import 'add_employees.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final searchController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService();
  List<EmployeeModel> _allEmployees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    searchController.addListener(_onSearchChanged);
  }

  void fetchEmployees() async {
    final employees = await _employeeService.getAllEmployees();
    setState(() {
      _allEmployees = employees;
      _filteredEmployees = employees;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _allEmployees.where((emp) {
        return emp.fullName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("Employee List"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? const Center(child: Text("No employees found."))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 284/133,
                        ),
                        itemCount: _filteredEmployees.length,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeDetailPage(
                            employeeId: employee.employeeId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 120,
                              height: 150,
                              color: Colors.grey[300],
                              child: employee.imageUrl.isNotEmpty
                                  ? Image.network(
                                employee.imageUrl,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.person,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Employee Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  employee.designation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                 "Email:${ employee.email}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                Text(
                                 "Contact:${ employee.phone ?? ''}",
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                // Text(
                                //   "Joining Date: ${employee.doj ?? ''}",
                                //   style: const TextStyle(fontSize: 13, color: Colors.grey),
                                // ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeDetailPage(
                                          employeeId: employee.employeeId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "View Details",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.teal[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_circle_right_outlined,
                                        size: 12,
                                        color: Colors.teal[600],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEmployeeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
