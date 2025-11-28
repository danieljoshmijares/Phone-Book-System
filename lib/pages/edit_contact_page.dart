import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../utils/phone_formatter.dart';

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
  late TextEditingController imageCtrl;
  List<TextEditingController> customKeyCtrls = [];
  List<TextEditingController> customValueCtrls = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing contact data

    nameCtrl = TextEditingController(text: widget.contact.name);
    numCtrl = TextEditingController(text: widget.contact.number);
    telCtrl = TextEditingController(text: widget.contact.tel);
    addrCtrl = TextEditingController(text: widget.contact.address);
    imageCtrl = TextEditingController(text: widget.contact.imageUrl);

    widget.contact.customFields.forEach((key, value) {
      customKeyCtrls.add(TextEditingController(text: key));
      customValueCtrls.add(TextEditingController(text: value));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Edit Contact',
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
                      const Text(
                        'Custom Fields',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Loop for all custom fields
                      for (int i = 0; i < customKeyCtrls.length; i++)
                        Row(
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

                      // Add new field button
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            customKeyCtrls.add(TextEditingController());
                            customValueCtrls.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Custom Field'),
                      ),
                    ],
                  ),

                  // ✅ PASTE THIS NEW CODE BLOCK AT THE <caret> LOCATION
                  Row(
                    children: [
                      // --- Clear Button ---
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // This logic clears all the text fields
                            nameCtrl.clear();
                            numCtrl.clear();
                            telCtrl.clear();
                            addrCtrl.clear();
                            imageCtrl.clear();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            // A neutral, secondary color
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
                      // --- Update Button ---
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            final phone = numCtrl.text.trim();
                            final tel = telCtrl.text.trim();
                            final addr = addrCtrl.text.trim();
                            final image = imageCtrl.text.trim();
                            Map<String, String> newCustomFields = {};

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

                            final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');

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
                              widget.contact.copyWith(
                                name: name,
                                number: phone,
                                tel: tel,
                                address: addr,
                                imageUrl: image,
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
                          icon: const Icon(Icons.update, color: Colors.white),
                          label: const Text(
                            'Update',

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

  // ✅ PASTE THIS NEW METHOD

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
