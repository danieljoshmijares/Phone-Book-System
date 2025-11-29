import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_user_page.dart';
import '../services/auth_service.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final Set<String> _touchedFields = {};

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Register',
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
                      _buildRequiredField('fullName', 'Full Name', fullNameCtrl),
                      const SizedBox(height: 12),
                      _buildRequiredField('email', 'Email', emailCtrl),
                      const SizedBox(height: 12),
                      _buildPasswordFieldWithValidation('password', 'Password', passwordCtrl),
                      const SizedBox(height: 12),
                      _buildRequiredPasswordField('confirmPassword', 'Confirm Password', confirmPasswordCtrl),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                        // CLEAR BUTTON ===================
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  fullNameCtrl.clear();
                                  emailCtrl.clear();
                                  passwordCtrl.clear();
                                  confirmPasswordCtrl.clear();
                                  _touchedFields.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: const Icon(Icons.clear_all, color: Colors.white),
                              label: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // REGISTER BUTTON ===================
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () async {
                                final fullName = fullNameCtrl.text.trim();
                                final email = emailCtrl.text.trim();
                                final password = passwordCtrl.text.trim();
                                final confirmPassword = confirmPasswordCtrl.text.trim();

                                if (fullName.isEmpty || email.isEmpty ||
                                    password.isEmpty || confirmPassword.isEmpty) {
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

                                if (!email.contains('@')) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Invalid Email'),
                                      content: const Text('Must be valid email address.'),
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

                                // Password strength validation
                                if (password.length < 8) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Weak Password'),
                                      content: const Text('Password must be at least 8 characters long.'),
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

                                if (!RegExp(r'[A-Z]').hasMatch(password)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Weak Password'),
                                      content: const Text('Password must contain at least one uppercase letter.'),
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

                                if (!RegExp(r'[a-z]').hasMatch(password)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Weak Password'),
                                      content: const Text('Password must contain at least one lowercase letter.'),
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

                                if (!RegExp(r'[0-9]').hasMatch(password)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Weak Password'),
                                      content: const Text('Password must contain at least one number.'),
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

                                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Weak Password'),
                                      content: const Text('Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>).'),
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

                                if (password != confirmPassword) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Password Mismatch'),
                                      content: const Text('Passwords do not match.'),
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

                                setState(() => _isLoading = true);

                                final result = await _authService.register(
                                  email: email,
                                  password: password,
                                  fullName: fullName,
                                );

                                setState(() => _isLoading = false);

                                if (result['success']) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.green.shade50,
                                      title: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Success!',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                        'Registration successful! Redirecting to login...',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );

                                  // Auto-dismiss after 2 seconds
                                  Future.delayed(const Duration(seconds: 2), () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginUserPage(),
                                      ),
                                    );
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Registration Failed'),
                                      content: Text(result['message']),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1976D2), // Material Blue 700
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.app_registration, color: Colors.white),
                              label: Text(
                                _isLoading ? 'Registering...' : 'Register',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login here',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
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

  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    final isPhoneField = label.contains('Phone');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhoneField
            ? [
                FilteringTextInputFormatter.digitsOnly, // numbers only
                LengthLimitingTextInputFormatter(15),
              ]
            : [], 
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      {bool isConfirm = false}) {
    final obscure = isConfirm ? _obscureConfirmPassword : _obscurePassword;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                if (isConfirm) {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                } else {
                  _obscurePassword = !_obscurePassword;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  // Required field with red asterisk and conditional error message
  Widget _buildRequiredField(String fieldName, String label, TextEditingController controller) {
    final isTouched = _touchedFields.contains(fieldName);
    final isEmpty = controller.text.trim().isEmpty;
    final showError = isTouched && isEmpty;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() {
            _touchedFields.add(fieldName);
          });
        }
      },
      child: TextField(
        controller: controller,
        onChanged: (_) {
          if (isTouched) {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          label: RichText(
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
          ),
          errorText: showError ? 'This is a required field' : null,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        ),
      ),
    );
  }

  // Password field with real-time validation checklist
  Widget _buildPasswordFieldWithValidation(String fieldName, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                _touchedFields.add(fieldName);
              });
            }
          },
          child: TextField(
            controller: controller,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              label: RichText(
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
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildPasswordChecklist(passwordCtrl.text),
      ],
    );
  }

  // Required password field (for confirm password)
  Widget _buildRequiredPasswordField(String fieldName, String label, TextEditingController controller) {
    final isTouched = _touchedFields.contains(fieldName);
    final isEmpty = controller.text.trim().isEmpty;
    final showError = isTouched && isEmpty;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() {
            _touchedFields.add(fieldName);
          });
        }
      },
      child: TextField(
        controller: controller,
        obscureText: _obscureConfirmPassword,
        onChanged: (_) {
          if (isTouched) {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          label: RichText(
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
          ),
          errorText: showError ? 'This is a required field' : null,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
      ),
    );
  }

  // Password requirements checklist that updates in real-time
  Widget _buildPasswordChecklist(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final meetsAll = hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('Must meet all requirements below', meetsAll),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          _buildRequirementItem('One number (0-9)', hasNumber),
          _buildRequirementItem('One special character (!@#\$%^&*)', hasSpecial),
        ],
      ),
    );
  }

  // Individual requirement item with checkmark/X
  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isMet ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
