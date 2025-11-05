import 'package:flutter/material.dart';
import '../models/contact.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;

  const EditContactPage({super.key, required this.contact});

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController nameCtrl;
  late TextEditingController numCtrl;
  late TextEditingController telCtrl;
  late TextEditingController addrCtrl;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing contact data
    nameCtrl = TextEditingController(text: widget.contact.name);
    numCtrl = TextEditingController(text: widget.contact.number);
    telCtrl = TextEditingController(text: widget.contact.tel);
    addrCtrl = TextEditingController(text: widget.contact.address);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Contact Info',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
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
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                children: [
                  _buildField('Full Name', nameCtrl),
                  _buildField('Phone Number', numCtrl),
                  _buildField('Tel. Number', telCtrl),
                  _buildField('Home Address', addrCtrl),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Validation: All fields must be filled
                      if (nameCtrl.text.trim().isEmpty ||
                          numCtrl.text.trim().isEmpty ||
                          telCtrl.text.trim().isEmpty ||
                          addrCtrl.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Missing Information'),
                            content: const Text('All fields are required.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Return updated contact to previous page
                      Navigator.pop(
                        context,
                        Contact(
                          name: nameCtrl.text.trim(),
                          number: numCtrl.text.trim(),
                          tel: telCtrl.text.trim(),
                          address: addrCtrl.text.trim(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Update Contact',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          enabled: true, // ✅ ensure fields are editable
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
