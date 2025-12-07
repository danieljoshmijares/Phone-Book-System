import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    String role = 'user', // Default role is 'user'
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Save user's full name and role to Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'disabled': false, // Track if account is disabled
        });

        // Log registration activity
        await _logActivity(
          email: email,
          fullName: fullName,
          role: role,
          action: 'register',
        );
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
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Check if user document exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          await _auth.signOut(); // Sign out immediately
          return {'success': false, 'message': 'This account has been deleted by an administrator'};
        }

        final userData = doc.data();

        // Check if account is disabled in Firestore
        if (userData != null && userData['disabled'] == true) {
          await _auth.signOut(); // Sign out immediately
          return {'success': false, 'message': 'This account has been disabled by an administrator'};
        }

        // Log login activity
        await _logActivity(
          email: userData?['email'] ?? email,
          fullName: userData?['fullName'] ?? 'User',
          role: userData?['role'] ?? 'user',
          action: 'login',
        );
      }

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

  // Get current user's role
  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'user';

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] ?? 'user'; // Default to 'user' if no role field
    } catch (e) {
      return 'user';
    }
  }

  // Log activity (register/login)
  Future<void> _logActivity({
    required String email,
    required String fullName,
    required String role,
    required String action,
  }) async {
    try {
      await _firestore.collection('activityLogs').add({
        'email': email,
        'fullName': fullName,
        'role': role,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }

  // Change password (requires current password for re-authentication)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      if (user.email == null) {
        return {'success': false, 'message': 'User email not found'};
      }

      // Re-authenticate with current password first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update to new password
      await user.updatePassword(newPassword);

      return {'success': true, 'message': 'Password changed successfully'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return {'success': false, 'message': 'Current password is incorrect'};
      } else if (e.code == 'weak-password') {
        return {'success': false, 'message': 'New password is too weak'};
      } else if (e.code == 'requires-recent-login') {
        return {'success': false, 'message': 'Please log out and log in again before changing password'};
      }
      return {'success': false, 'message': 'Password change failed: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Password change failed: $e'};
    }
  }

  // Validate current user's session (check if account still exists and is not disabled)
  Future<Map<String, dynamic>> validateSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'valid': false, 'reason': 'not_logged_in'};
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      // Check if user document exists
      if (!doc.exists) {
        await _auth.signOut();
        return {'valid': false, 'reason': 'account_deleted'};
      }

      final userData = doc.data();

      // Check if account is disabled
      if (userData != null && userData['disabled'] == true) {
        await _auth.signOut();
        return {'valid': false, 'reason': 'account_disabled'};
      }

      return {'valid': true};
    } catch (e) {
      return {'valid': false, 'reason': 'error', 'error': e.toString()};
    }
  }

  // Initialize Super Admin with credentials from .env file
  Future<void> initializeSuperAdmin() async {
    final superAdminEmail = dotenv.env['SUPER_ADMIN_EMAIL'] ?? '';
    final superAdminPassword = dotenv.env['SUPER_ADMIN_PASSWORD'] ?? '';
    const superAdminName = 'Super Administrator';

    // Validate credentials are loaded
    if (superAdminEmail.isEmpty || superAdminPassword.isEmpty) {
      print('ERROR: Super Admin credentials not found in .env file');
      return;
    }

    try {
      // Check if Super Admin already exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: superAdminEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create Super Admin account
        await register(
          email: superAdminEmail,
          password: superAdminPassword,
          fullName: superAdminName,
          role: 'superadmin',
        );
        print('Super Admin account created successfully');
      }
    } catch (e) {
      print('Super Admin initialization failed: $e');
    }
  }
}
