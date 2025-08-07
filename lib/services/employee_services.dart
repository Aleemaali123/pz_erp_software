import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pz_erp_software/model/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔵 Get only active employees
  Future<List<EmployeeModel>> getAllActiveEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("employees")
          .where('status', isEqualTo: 'Active')
          .get();

      return snapshot.docs
          .map((doc) => EmployeeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching active employees: $e");
    }
  }

  // 🔴 Get all employees (active and inactive)
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("employees").get();

      return snapshot.docs
          .map((doc) => EmployeeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error fetching all employees: $e");
    }
  }
}
