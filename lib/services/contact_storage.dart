import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

class ContactStorage {
  static const String _key = 'contacts';

  // Save contacts to storage
  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert list of contacts to JSON
    final List<Map<String, dynamic>> jsonList =
        contacts.map((contact) => contact.toJson()).toList();

    // Convert to string and save
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_key, jsonString);
  }

  // Load contacts from storage
  static Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the JSON string
    final String? jsonString = prefs.getString(_key);

    // If no data exists, return empty list
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      // Parse JSON string to list
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert to Contact objects
      return jsonList
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  // Clear all contacts from storage
  static Future<void> clearContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
