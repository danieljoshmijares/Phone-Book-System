import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get user's contacts collection reference
  CollectionReference? _getUserContactsCollection() {
    final userId = _authService.getUserId();
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('contacts');
  }

  // Load all contacts for current user
  Future<List<Contact>> loadContacts() async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return [];

      final snapshot = await collection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Contact(
          name: data['name'] ?? '',
          number: data['number'] ?? '',
          tel: data['tel'] ?? '',
          address: data['address'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          customFields: Map<String, String>.from(data['customFields'] ?? {}),
        );
      }).toList();
    } catch (e) {
      print('Error loading contacts: $e');
      return [];
    }
  }

  // Save all contacts for current user
  Future<void> saveContacts(List<Contact> contacts) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      // Delete all existing contacts
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Add all contacts
      for (var contact in contacts) {
        await collection.add({
          'name': contact.name,
          'number': contact.number,
          'tel': contact.tel,
          'address': contact.address,
          'imageUrl': contact.imageUrl ?? '',
          'customFields': contact.customFields,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving contacts: $e');
    }
  }

  // Add a single contact
  Future<void> addContact(Contact contact) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      await collection.add({
        'name': contact.name,
        'number': contact.number,
        'tel': contact.tel,
        'address': contact.address,
        'imageUrl': contact.imageUrl ?? '',
        'customFields': contact.customFields,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding contact: $e');
    }
  }

  // Delete all contacts (for bulk delete)
  Future<void> deleteContacts() async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting contacts: $e');
    }
  }
}
