import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login by verifying credentials from Firestore "admin" collection
  Future<User?> loginAdmin(String email, String password) async {
    try {
      // Fetch admin document with matching email
      final querySnapshot = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password) // Not secure, for demo only
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Invalid email or password");
      }
      final adminDoc = querySnapshot.docs.first;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }
}
