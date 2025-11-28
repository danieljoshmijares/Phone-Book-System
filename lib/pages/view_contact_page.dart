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

  Widget _buildProfileImage() {
    final hasImage = contact.imageUrl != null && contact.imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasImage ? NetworkImage(contact.imageUrl!) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, size: 60, color: Colors.black54),
    );
  }

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 20),
                    // White card container with contact info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mobile Number
                          const Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.number,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tel Number
                          const Text(
                            'Tel Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.tel,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Home Address
                          const Text(
                            'Home Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.address,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (contact.customFields.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Other Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),

                            for (var entry in contact.customFields.entries)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],

                          // Buttons row (now inside container)
                          Row(
                            children: [
                              // Delete Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Show confirmation dialog
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Contact'),
                                        content: const Text(
                                          'Are you sure you want to delete 1 contact?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Proceed Anyway',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    // If confirmed, delete and go back
                                    if (confirm == true) {
                                      onDelete();
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Edit Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final updated =
                                        await Navigator.push<Contact>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditContactPage(
                                                  contact: contact,
                                                ),
                                          ),
                                        );
                                    if (updated != null) {
                                      contact.name = updated.name;
                                      contact.number = updated.number;
                                      contact.tel = updated.tel;
                                      contact.address = updated.address;
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF1976D2,
                                    ), // Material Blue 700
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
