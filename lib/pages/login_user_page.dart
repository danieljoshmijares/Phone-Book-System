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

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      _buildField('Email', emailCtrl, isPassword: false),
                      _buildPasswordField('Password', passwordCtrl),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // CLEAR BUTTON==========
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                emailCtrl.clear();
                                passwordCtrl.clear();
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
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/home',
                                    (route) => false,
                                  );
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
}
