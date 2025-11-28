import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // LIMIT to 10 digits max
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    if (digits.length >= 1) {
      formatted = digits.substring(0, digits.length.clamp(0, 3));
    }
    if (digits.length > 3) {
      formatted += '-' + digits.substring(3, digits.length.clamp(3, 6));
    }
    if (digits.length > 6) {
      formatted += '-' + digits.substring(6, digits.length.clamp(6, 10));
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
