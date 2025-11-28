import 'package:flutter/services.dart';

// Phone Number Formatter: XXXX-XXX-XXXX (10 digits)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // LIMIT to 10 digits max
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    String formatted = '';

    if (digits.length >= 1) {
      formatted = digits.substring(0, digits.length.clamp(0, 4));
    }
    if (digits.length > 4) {
      formatted += '-' + digits.substring(4, digits.length.clamp(4, 7));
    }
    if (digits.length > 7) {
      formatted += '-' + digits.substring(7, digits.length.clamp(7, 11));
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Telephone Number Formatter: XXX-XXXX (7 digits)
class TelephoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // LIMIT to 7 digits max
    if (digits.length > 7) {
      digits = digits.substring(0, 7);
    }

    String formatted = '';

    if (digits.length >= 1) {
      formatted = digits.substring(0, digits.length.clamp(0, 3));
    }
    if (digits.length > 3) {
      formatted += '-' + digits.substring(3, digits.length.clamp(3, 7));
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
