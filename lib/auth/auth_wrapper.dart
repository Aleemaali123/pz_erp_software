import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Checking connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen(); // Replace with your actual HomeScreen
        }

        // If not logged in
        return const AdminLoginScreen();
      },
    );
  }
}
