import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../model/employee_model.dart';
import '../theme/color_theme.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;
  File? profileImage;
  DateTime? _dateOfJoining;
  bool _isActive = true;

  // Use a PlatformFile for web and File for other platforms
  PlatformFile? pickedFile;
  Uint8List? fileBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<String> generateEmployeeId() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('employees').get();
    int count = snapshot.docs.length + 1;
    String id = 'pz${count.toString().padLeft(2, '0')}';
    return id;
  }

  void _selectDateOfJoining() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateOfJoining = picked;
      });
    }
  }

  Future<void> pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        pickedFile = result.files.single;
        if (kIsWeb) {
          fileBytes = pickedFile!.bytes as Uint8List?;
        }
      });
    }
  }

  // --- UPDATED METHOD ---
  Future<Map<String, String>?> uploadProfileImage(String employeeId) async {
    if (pickedFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('employee_images')
          .child('$employeeId.jpg');

      TaskSnapshot uploadTask;
      if (kIsWeb) {
        uploadTask = await storageRef.putData(pickedFile!.bytes!);
      } else {
        uploadTask = await storageRef.putFile(File(pickedFile!.path!));
      }

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      final profilePath = storageRef.fullPath;

      print('Image uploaded successfully. URL: $downloadUrl'); // Debug print
      return {
        'imageUrl': downloadUrl,
        'profilePath': profilePath,
      };
    } on FirebaseException catch (e) {
      // Throw the specific FirebaseException for better debugging
      print('Firebase Storage Error: ${e.message}');
      rethrow;
    } catch (e) {
      // Throw any other generic exception
      print('General Upload Error: $e');
      rethrow;
    }
  }

  // --- UPDATED METHOD ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_dateOfJoining == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of joining')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String employeeId = await generateEmployeeId();

        String? imageUrl;
        String? profilePath;

        if (pickedFile != null) {
          final uploadResult = await uploadProfileImage(employeeId);
          imageUrl = uploadResult!['imageUrl'];
          profilePath = uploadResult['profilePath'];
        }

        EmployeeModel employee = EmployeeModel(
          employeeId: employeeId,
          profilePath: profilePath ?? '',
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender ?? "",
          department: _departmentController.text.trim(),
          designation: _designationController.text.trim(),
          address: _addressController.text.trim(),
          status: _isActive ? 'Active' : 'Inactive',
          doj: _dateOfJoining!,
          imageUrl: imageUrl ?? '',
        );

        await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeId)
            .set(employee.toMap());

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          // Display the error message from the exception
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding employee: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Add New Employee"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(children: [
                            // Profile image with border
                            InkWell(
                              onTap: () {
                                pickProfileImage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: fileBytes != null && kIsWeb
                                      ? MemoryImage(fileBytes!)
                                      : pickedFile != null && !kIsWeb
                                          ? FileImage(File(pickedFile!.path!))
                                          : null,
                                  child: pickedFile == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ]),
                        ),

                        // Edit icon button on bottom right

                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildTextField(
                                  _nameController, "Full Name", Icons.person),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildTextField(
                                  _emailController, "Email", Icons.email,
                                  keyboardType: TextInputType.emailAddress),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                  _phoneController, "Phone Number", Icons.phone,
                                  keyboardType: TextInputType.phone),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildGenderDropdown(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildTextField(_departmentController,
                                  "Department", Icons.account_tree_outlined),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildTextField(_designationController,
                                  "Designation", Icons.badge_outlined),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildTextField(
                            _addressController, "Address", Icons.location_on,
                            maxLines: 2),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: _selectDateOfJoining,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "Date of Joining",
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    _dateOfJoining != null
                                        ? DateFormat('dd MMM yyyy')
                                            .format(_dateOfJoining!)
                                        : 'Select Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _dateOfJoining != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   // child: Icon(Icons.toggle_on,
                            //   //     size: 30,
                            //   //     color: _isActive ? Colors.green : Colors.red),
                            // ),
                            //const SizedBox(width: 10),
                            const Text("Status",
                                style: TextStyle(fontSize: 16)),
                            // const Spacer(),
                            SizedBox(
                              width: 15,
                            ),
                            Switch(
                              value: _isActive,
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              onChanged: (value) =>
                                  setState(() => _isActive = value),
                            ),
                            Text(
                              _isActive ? "Active" : "Inactive",
                              style: TextStyle(
                                  color: _isActive ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row(
                        //   children: [
                        //     Icon(Icons.toggle_on,
                        //         size: 30,
                        //         color: _isActive ? Colors.green : Colors.red),
                        //     const SizedBox(width: 10),
                        //     const Text("Status",
                        //         style: TextStyle(fontSize: 16)),
                        //     const Spacer(),
                        //     Switch(
                        //       value: _isActive,
                        //       activeColor: Colors.green,
                        //       inactiveThumbColor: Colors.red,
                        //       onChanged: (value) =>
                        //           setState(() => _isActive = value),
                        //     ),
                        //     Text(
                        //       _isActive ? "Active" : "Inactive",
                        //       style: TextStyle(
                        //           color: _isActive ? Colors.green : Colors.red),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.check),
                            label: const Text("Add Employee",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ])),
            )));
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      validator: (value) =>
          value == null || value.isEmpty ? "Please select gender" : null,
      onChanged: (value) {
        setState(() {
          value = _selectedGender!;
        });
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? "Please enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
        ),
      ),
    );
  }
}
