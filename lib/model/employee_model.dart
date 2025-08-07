import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String employeeId;
  final String? profilePath;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String department;
  final String designation;
  final String address;
  final String status;
  final DateTime doj;
  final String imageUrl;
  final DateTime? createdAt;

  EmployeeModel({
    required this.employeeId,
    this.profilePath,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.department,
    required this.designation,
    required this.address,
    required this.status,
    required this.doj,
    this.createdAt,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'profilePath': profilePath,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'department': department,
      'designation': designation,
      'address': address,
      'status': status,
      'doj': doj,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      employeeId: map['employeeId'] ?? '',
      profilePath: map['profilePath'],
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      doj: map['doj'] != null ? (map['doj'] as Timestamp).toDate() : DateTime.now(),
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

}
