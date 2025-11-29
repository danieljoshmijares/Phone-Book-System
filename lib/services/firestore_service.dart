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
          id: doc.id, // Store the Firestore document ID
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

  // Save all contacts for current user (DEPRECATED - use addContact/updateContact instead)
  // Only kept for backward compatibility, but now properly updates by ID
  Future<void> saveContacts(List<Contact> contacts) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      // Update or add each contact based on whether it has an ID
      for (var contact in contacts) {
        if (contact.id != null) {
          // Update existing contact
          await collection.doc(contact.id).set({
            'name': contact.name,
            'number': contact.number,
            'tel': contact.tel,
            'address': contact.address,
            'imageUrl': contact.imageUrl ?? '',
            'customFields': contact.customFields,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          // Add new contact (this shouldn't happen if we use addContact properly)
          final docRef = await collection.add({
            'name': contact.name,
            'number': contact.number,
            'tel': contact.tel,
            'address': contact.address,
            'imageUrl': contact.imageUrl ?? '',
            'customFields': contact.customFields,
            'createdAt': FieldValue.serverTimestamp(),
          });
          contact.id = docRef.id; // Store the new ID
        }
      }
    } catch (e) {
      print('Error saving contacts: $e');
    }
  }

  // Add a single contact and return the ID
  Future<String?> addContact(Contact contact) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return null;

      final docRef = await collection.add({
        'name': contact.name,
        'number': contact.number,
        'tel': contact.tel,
        'address': contact.address,
        'imageUrl': contact.imageUrl ?? '',
        'customFields': contact.customFields,
        'createdAt': FieldValue.serverTimestamp(),
      });

      contact.id = docRef.id; // Store the ID in the contact object
      return docRef.id;
    } catch (e) {
      print('Error adding contact: $e');
      return null;
    }
  }

  // Update a single contact by ID
  Future<void> updateContact(Contact contact) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null || contact.id == null) return;

      await collection.doc(contact.id).update({
        'name': contact.name,
        'number': contact.number,
        'tel': contact.tel,
        'address': contact.address,
        'imageUrl': contact.imageUrl ?? '',
        'customFields': contact.customFields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating contact: $e');
    }
  }

  // Delete a single contact by ID
  Future<void> deleteContact(String contactId) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      await collection.doc(contactId).delete();
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  // Delete multiple contacts by their IDs
  Future<void> deleteMultipleContacts(List<String> contactIds) async {
    try {
      final collection = _getUserContactsCollection();
      if (collection == null) return;

      for (var id in contactIds) {
        await collection.doc(id).delete();
      }
    } catch (e) {
      print('Error deleting contacts: $e');
    }
  }
}
