import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../utils/phone_formatter.dart';

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
  final imageCtrl = TextEditingController();
  List<TextEditingController> customKeyCtrls = [];
  List<TextEditingController> customValueCtrls = [];

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
                  _buildField('Image URL (optional)', imageCtrl),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Add new field text (clickable)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            customKeyCtrls.add(TextEditingController());
                            customValueCtrls.add(TextEditingController());
                          });
                        },
                        child: const Text(
                          '+ Add Custom Field',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Loop for all custom fields (they appear below the text)
                      for (int i = 0; i < customKeyCtrls.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: customKeyCtrls[i],
                                  decoration: const InputDecoration(
                                    labelText: 'Field Name',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: customValueCtrls[i],
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    customKeyCtrls.removeAt(i);
                                    customValueCtrls.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // ✅ PASTE THIS NEW CODE BLOCK
                  Row(
                    children: [
                      // --- Clear Button ---
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            nameCtrl.clear();
                            numCtrl.clear();
                            telCtrl.clear();
                            addrCtrl.clear();
                            imageCtrl.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(
                            Icons.clear_all,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10), // Space between the buttons
                      // --- Save Button ---
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            final phone = numCtrl.text.trim();
                            final tel = telCtrl.text.trim();
                            final addr = addrCtrl.text.trim();
                            Map<String, String> newCustomFields = {};

                            final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');

                            for (int i = 0; i < customKeyCtrls.length; i++) {
                              final k = customKeyCtrls[i].text.trim();
                              final v = customValueCtrls[i].text.trim();

                              if (k.isNotEmpty) {
                                newCustomFields[k] = v;
                              }
                            }

                            // ------- REQUIRED CHECKS -------
                            if (name.isEmpty ||
                                phone.isEmpty ||
                                tel.isEmpty ||
                                addr.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Missing Information'),
                                  content: const Text(
                                    'All fields are required.',
                                  ),
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

                            // ------- FORMAT CHECKS -------
                            if (!regex.hasMatch(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Phone Number must be XXX-XXX-XXXX',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!regex.hasMatch(tel)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Telephone Number must be XXX-XXX-XXXX',
                                  ),
                                ),
                              );
                              return;
                            }

                            // ------- IF ALL VALID → SAVE -------
                            Navigator.pop(
                              context,
                              Contact(
                                name: nameCtrl.text.trim(),
                                number: numCtrl.text.trim(),
                                tel: telCtrl.text.trim(),
                                address: addrCtrl.text.trim(),
                                imageUrl: imageCtrl.text.trim(),
                                customFields: newCustomFields,
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF1976D2,
                            ), // Material Blue 700
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save',
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
    final isPhoneField =
        label.contains('Phone Number') || label.contains('Tel. Number');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // ✅ ADD THESE NEW PROPERTIES
        // Use number pad for phone fields, default for others
        keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
        // Apply strict input rules for phone fields
        inputFormatters: isPhoneField
            ? [
                PhoneNumberFormatter(),
                // Allow only numbers
                LengthLimitingTextInputFormatter(12),
                // Limit to 12 digits
              ]
            : [], // No formatters for other fields
      ),
    );
  }
}
