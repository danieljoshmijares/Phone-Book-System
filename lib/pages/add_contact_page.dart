import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';

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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  _buildField('Full Name', nameCtrl),
                  _buildField('Phone Number', numCtrl),
                  _buildField('Tel. Number', telCtrl),
                  _buildField('Home Address', addrCtrl),
                  const SizedBox(height: 20),
                  // ✅ PASTE THIS NEW CODE BLOCK
                  Row(
                    children: [ // --- Clear Button ---
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            nameCtrl.clear();
                            numCtrl.clear();
                            telCtrl.clear();
                            addrCtrl.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10), // Space between the buttons

                      // --- Save Button ---
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Trim inputs and validate all fields
                            if (nameCtrl.text
                                .trim()
                                .isEmpty ||
                                numCtrl.text
                                    .trim()
                                    .isEmpty ||
                                telCtrl.text
                                    .trim()
                                    .isEmpty ||
                                addrCtrl.text
                                    .trim()
                                    .isEmpty) {
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
                            'Save', // Shorter name
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
        ),
        ),
        ),
      );

  // REPLACE your old _buildField method with this one
  Widget _buildField(String label, TextEditingController controller) {
    // Determine if this is a phone number field
    final isPhoneField = label.contains('Phone Number') ||
        label.contains('Tel. Number');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // ✅ ADD THESE NEW PROPERTIES
        // Use number pad for phone fields, default for others
        keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
        // Apply strict input rules for phone fields
        inputFormatters: isPhoneField
            ? [
          FilteringTextInputFormatter.digitsOnly,
          // Allow only numbers
          LengthLimitingTextInputFormatter(15),
          // Limit to 15 digits (a reasonable max)
        ]
            : [], // No formatters for other fields
      ),
    );
  }
}
