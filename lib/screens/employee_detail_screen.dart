import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pz_erp_software/theme/color_theme.dart';

class EmployeeDetailPage extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  bool isEditing = false;
  String currentStatus = '';
  bool dataLoaded = false;

  final Map<String, TextEditingController> _controllers = {
    'fullName': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'gender': TextEditingController(),
    'address': TextEditingController(),
    'status': TextEditingController(),
    'designation': TextEditingController(),
    'department': TextEditingController(),
    'joiningDate': TextEditingController(),
  };

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic> data) {
    if (dataLoaded) return;

    _controllers['fullName']!.text = data['fullName'] ?? '';
    _controllers['email']!.text = data['email'] ?? '';
    _controllers['phone']!.text = data['phone'] ?? '';
    _controllers['gender']!.text = data['gender'] ?? '';
    _controllers['address']!.text = data['address'] ?? '';
    _controllers['status']!.text = data['status'] ?? '';
    _controllers['designation']!.text = data['designation'] ?? '';
    _controllers['department']!.text = data['department'] ?? '';

    final dojTimestamp = data['doj'] as Timestamp?;
    final joiningDate = dojTimestamp != null
        ? DateFormat('dd-MM-yyyy').format(dojTimestamp.toDate())
        : '';
    _controllers['joiningDate']!.text = joiningDate;
    currentStatus = data['status'] ?? 'Active';
    dataLoaded = true;
  }

  Future<void> _saveChanges(String docId) async {
    await FirebaseFirestore.instance.collection('employees').doc(docId).update({
      'fullName': _controllers['fullName']!.text,
      'email': _controllers['email']!.text,
      'phone': _controllers['phone']!.text,
      'gender': _controllers['gender']!.text,
      'address': _controllers['address']!.text,
      'status': currentStatus,
      'designation': _controllers['designation']!.text,
      'department': _controllers['department']!.text,
    });

    setState(() {
      isEditing = false;
      _controllers['status']!.text = currentStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('employees')
        .where('employeeId', isEqualTo: widget.employeeId);

    return FutureBuilder<QuerySnapshot>(
      future: query.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Employee not found.')),
          );
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        _populateControllers(data);

        final fullName = data['fullName'] ?? 'Employee Details';
        final designation = data['designation'] ?? '';
        final imageUrl = data['imageUrl'] ?? '';

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(fullName),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              if (isEditing)
                Row(
                  children: [
                    Text(
                      currentStatus,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Switch(
                      value: currentStatus == 'Active',
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value ? 'Active' : 'Inactive';
                        });
                      },
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  if (isEditing) {
                    _saveChanges(doc.id);
                  } else {
                    setState(() => isEditing = true);
                  }
                },
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => setState(() => isEditing = false),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/petzify.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: -60,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designation,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildRowFields('fullName', 'email'),
                            const SizedBox(height: 16),
                            _buildRowFields('phone', 'gender'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: _buildField('Address', 'address'),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildField('Status', 'status'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildRowFields('joiningDate', 'designation'),
                            const SizedBox(height: 16),
                            _buildRowFields('department', 'status'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRowFields(String key1, String key2) {
    return Row(
      children: [
        Expanded(child: _buildField(_capitalize(key1), key1)),
        const SizedBox(width: 16),
        Expanded(child: _buildField(_capitalize(key2), key2)),
      ],
    );
  }

  Widget _buildField(String label, String key) {
    return TextFormField(
      controller: _controllers[key],
      readOnly: !isEditing || key == 'joiningDate' || key == 'status',
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
