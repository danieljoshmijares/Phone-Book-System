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
  final Set<String> _touchedFields = {};

  bool _canAddCustomField() {
    if (customKeyCtrls.isEmpty) return true;
    final lastIndex = customKeyCtrls.length - 1;
    return customKeyCtrls[lastIndex].text.trim().isNotEmpty &&
           customValueCtrls[lastIndex].text.trim().isNotEmpty;
  }

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
                  _buildRequiredField('name', 'Full Name', nameCtrl, isRequired: true),
                  const SizedBox(height: 12),
                  _buildRequiredField('phone', 'Phone Number', numCtrl, isRequired: true),
                  const SizedBox(height: 12),
                  _buildRequiredField('tel', 'Tel. Number', telCtrl, isRequired: true),
                  const SizedBox(height: 12),
                  _buildRequiredField('address', 'Home Address', addrCtrl, isRequired: true),
                  const SizedBox(height: 12),
                  _buildRequiredField('image', 'Image URL', imageCtrl, isRequired: false),

                  const SizedBox(height: 16),

                  // Loop for all custom fields
                  for (int i = 0; i < customKeyCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customKeyCtrls[i],
                              decoration: InputDecoration(
                                labelText: 'Field Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: customValueCtrls[i],
                              decoration: InputDecoration(
                                labelText: 'Value',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onChanged: (_) => setState(() {}),
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

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Add Custom Field Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _canAddCustomField()
                              ? () {
                                  setState(() {
                                    customKeyCtrls.add(TextEditingController());
                                    customValueCtrls.add(TextEditingController());
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            disabledBackgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Custom Field',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      // Update Button
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

                            final phoneRegex = RegExp(r'^\d{4}-\d{3}-\d{4}$');
                            final telRegex = RegExp(r'^\d{3}-\d{4}$');

                            if (!phoneRegex.hasMatch(phone)) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Invalid Format'),
                                  content: const Text(
                                    'Phone Number must be XXXX-XXX-XXXX',
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

                            if (!telRegex.hasMatch(tel)) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Invalid Format'),
                                  content: const Text(
                                    'Telephone Number must be XXX-XXXX',
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

  Widget _buildField(String label, TextEditingController controller) {
    final isPhoneField = label.contains('Phone Number');
    final isTelField = label.contains('Tel. Number');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => controller.clear(),
                    )
                  : null,
            ),
            keyboardType: (isPhoneField || isTelField) ? TextInputType.phone : TextInputType.text,
            inputFormatters: isPhoneField
                ? [
                    PhoneNumberFormatter(),
                    LengthLimitingTextInputFormatter(13), // XXXX-XXX-XXXX (10 digits + 2 dashes)
                  ]
                : isTelField
                    ? [
                        TelephoneNumberFormatter(),
                        LengthLimitingTextInputFormatter(8), // XXX-XXXX (7 digits + 1 dash)
                      ]
                    : [],
          );
        },
      ),
    );
  }

  // Required field with red asterisk and conditional error message for Edit Contact
  Widget _buildRequiredField(String fieldName, String label, TextEditingController controller, {required bool isRequired}) {
    final isPhoneField = label.contains('Phone Number');
    final isTelField = label.contains('Tel. Number');
    final isTouched = _touchedFields.contains(fieldName);
    final isEmpty = controller.text.trim().isEmpty;
    final showError = isRequired && isTouched && isEmpty;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() {
            _touchedFields.add(fieldName);
          });
        }
      },
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            onChanged: (_) {
              if (isTouched) {
                setState(() {});
              }
            },
            decoration: InputDecoration(
              label: isRequired
                  ? RichText(
                      text: TextSpan(
                        text: label,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Text(label),
              errorText: showError ? 'This is a required field' : null,
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              helperText: !isRequired ? '(Optional)' : null,
              helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: showError ? Colors.red : Colors.grey,
                  width: showError ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: showError ? Colors.red : const Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => controller.clear(),
                    )
                  : null,
            ),
            keyboardType: (isPhoneField || isTelField) ? TextInputType.phone : TextInputType.text,
            inputFormatters: isPhoneField
                ? [
                    PhoneNumberFormatter(),
                    LengthLimitingTextInputFormatter(13),
                  ]
                : isTelField
                    ? [
                        TelephoneNumberFormatter(),
                        LengthLimitingTextInputFormatter(8),
                      ]
                    : [],
          );
        },
      ),
    );
  }
}
