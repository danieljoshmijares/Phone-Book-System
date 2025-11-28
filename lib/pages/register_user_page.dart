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
                      _buildField('Full Name', fullNameCtrl, isPassword: false),
                      _buildField('Email', emailCtrl, isPassword: false),
                      _buildPasswordField('Password', passwordCtrl),
                      _buildPasswordField('Confirm Password', confirmPasswordCtrl, isConfirm: true),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                        // CLEAR BUTTON ===================
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                fullNameCtrl.clear();
                                emailCtrl.clear();
                                passwordCtrl.clear();
                                confirmPasswordCtrl.clear();
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
                                    builder: (context) => AlertDialog(
                                      title: const Text('Success'),
                                      content: const Text('Registration successful! Please login.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const LoginUserPage(),
                                              ),
                                            );
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
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
}
