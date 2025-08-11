// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/auth_service.dart';
//
// class AdminRegisterScreen extends StatefulWidget {
//   const AdminRegisterScreen({super.key});
//
//   @override
//   State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
// }
//
// class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _authService = AuthService();
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _isLoading = false;
//
//   void _registerAdmin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       try {
//         User? user = await _authService.registerAdmin(
//           name: _nameController.text.trim(),
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//
//         if (user != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Registration successful')),
//           );
//           Navigator.pop(context); // Go back to login
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff4f6f8),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Card(
//             elevation: 6,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset('assets/logo.jpg', height: 100),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Admin Register',
//                       style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Name',
//                         prefixIcon: Icon(Icons.person),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                       value != null && value.isNotEmpty ? null : 'Enter your name',
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                       value != null && value.contains('@') ? null : 'Enter a valid email',
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: Icon(Icons.lock),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                       value != null && value.length >= 6 ? null : 'Minimum 6 characters',
//                     ),
//                     const SizedBox(height: 24),
//                     _isLoading
//                         ? const CircularProgressIndicator()
//                         : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: _registerAdmin,
//                         child: const Text('Register', style: TextStyle(fontSize: 16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
