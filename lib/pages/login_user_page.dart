import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_user_page.dart';
import '../services/auth_service.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final Set<String> _touchedFields = {};

  @override
  void initState() {
    super.initState();
    // Clear everything when page loads (fresh start)
    emailCtrl.clear();
    passwordCtrl.clear();
    _touchedFields.clear();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Login',
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
                      _buildRequiredField('email', 'Email', emailCtrl),
                      const SizedBox(height: 12),
                      _buildRequiredPasswordField('password', 'Password', passwordCtrl),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // CLEAR BUTTON==========
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  emailCtrl.clear();
                                  passwordCtrl.clear();
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


                          //=======LOGIN BUTTON==========
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () async {
                                final email = emailCtrl.text.trim();
                                final password = passwordCtrl.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Missing Information'),
                                      content: const Text('Email and Password are required.'),
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

                                final result = await _authService.signIn(
                                  email: email,
                                  password: password,
                                );

                                setState(() => _isLoading = false);

                                if (result['success']) {
                                  // Check user role and route accordingly
                                  final role = await _authService.getUserRole();

                                  String redirectMessage;
                                  String redirectRoute;

                                  if (role == 'superadmin') {
                                    redirectMessage = 'Welcome back, Super Admin!';
                                    redirectRoute = '/superadmin';
                                  } else if (role == 'admin') {
                                    redirectMessage = 'Welcome back, Admin!';
                                    redirectRoute = '/admin';
                                  } else {
                                    redirectMessage = 'Welcome back! Redirecting to your phonebook...';
                                    redirectRoute = '/home';
                                  }

                                  // Show success notification
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
                                            'Login Successful!',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        redirectMessage,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );

                                  // Auto-dismiss after 2 seconds
                                  Future.delayed(const Duration(seconds: 2), () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      redirectRoute,
                                      (route) => false,
                                    );
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Login Failed'),
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
                                  : const Icon(Icons.login, color: Colors.white),
                              label: Text(
                                _isLoading ? 'Logging in...' : 'Login',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // REGISTER LINK ===================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterUserPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register here',
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
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false}) {
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
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: label,
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

  // Required password field with red asterisk and conditional error message
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
        obscureText: _obscurePassword,
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
    );
  }
}
