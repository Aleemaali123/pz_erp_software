import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register new admin and store in 'admin' collection
  Future<User?> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create account in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Save additional admin details in Firestore under 'admin' collection
        await _firestore.collection('admin').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Admin registration failed');
    }
  }

  /// Login existing admin
  Future<User?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Admin login failed');
    }
  }

  /// Logout admin
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current admin
  User? get currentAdmin => _auth.currentUser;
}
