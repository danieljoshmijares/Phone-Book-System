import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'edit_contact_page.dart';

class ViewContactPage extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDelete; // callback to delete the contact

  const ViewContactPage({
    super.key,
    required this.contact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Contact',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Name
              const Text(
                'Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(contact.name, style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 12),
              // Mobile Number
              const Text(
                'Mobile Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(contact.number, style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 12),
              // Tel Number
              const Text(
                'Tel Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(contact.tel, style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 12),
              // Home Address
              const Text(
                'Home Address:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(contact.address, style: const TextStyle(fontSize: 18, color: Colors.white)),
              const Spacer(),
              // ==================== BUTTONS ====================
              Row(
                children: [ // Note: children, not mainAxisAlignment anymore
                  // --- Delete Button ---
                  Expanded( // ✅ WRAP the button with Expanded
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // delete the contact via callback and pop
                        onDelete();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // No shape, no horizontal padding needed
                      ),
                    ),
                  ),

                  const SizedBox(width: 10), // ✅ ADD space between the buttons

                  // --- Edit Button ---
                  Expanded( // ✅ WRAP this button too
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final updated = await Navigator.push<Contact>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditContactPage(contact: contact),
                          ),
                        );
                        if (updated != null) {
                          // Update the contact details and pop back to HomePage
                          contact.name = updated.name;
                          contact.number = updated.number;
                          contact.tel = updated.tel;
                          contact.address = updated.address;
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                          Icons.edit_outlined, color: Colors.white),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // No shape, no horizontal padding needed
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
