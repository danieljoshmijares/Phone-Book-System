import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user's full name
  Future<String> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user == null) return 'User';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['fullName'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  // Register with email, password, and full name
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Save user's full name to Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'Registration successful'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {'success': false, 'message': 'Password is too weak'};
      } else if (e.code == 'email-already-in-use') {
        return {'success': false, 'message': 'Email already in use'};
      } else if (e.code == 'invalid-email') {
        return {'success': false, 'message': 'Invalid email address'};
      }
      return {'success': false, 'message': 'Registration failed: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'message': 'Login successful'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {'success': false, 'message': 'No user found with this email'};
      } else if (e.code == 'wrong-password') {
        return {'success': false, 'message': 'Incorrect password'};
      } else if (e.code == 'invalid-email') {
        return {'success': false, 'message': 'Invalid email address'};
      } else if (e.code == 'user-disabled') {
        return {'success': false, 'message': 'This account has been disabled'};
      }
      return {'success': false, 'message': 'Login failed: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }
}
