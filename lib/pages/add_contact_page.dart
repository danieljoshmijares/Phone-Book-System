import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../main.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final nameCtrl = TextEditingController();
  final numCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final addrCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Add Contact',
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
                      // Trim inputs and validate all fields
                      if (nameCtrl.text.trim().isEmpty ||
                          numCtrl.text.trim().isEmpty ||
                          telCtrl.text.trim().isEmpty ||
                          addrCtrl.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Missing Information'),
                              content:
                                  const Text('All fields are required.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return; // Stop execution if validation fails
                      }

                      // Save contact and go back
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
                      'Save Contact',
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
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
