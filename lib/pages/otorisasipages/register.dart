import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/pages/otorisasipages/login.dart';
import 'package:icons_plus/icons_plus.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true, _obscureTexts = true, _isLoading = false;

  // Validasi form dan registrasi
  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi inputan form
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog("Semua Fied Harus Keisi");
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kirim request registrasi ke backend
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        // Setelah registrasi berhasil, kirim email verifikasi
        await _sendVerificationEmail(email);
      } else {
        _showErrorDialog(
            jsonDecode(response.body)['error'] ?? "An error occurred.");
      }
    } catch (_) {
      _showErrorDialog("Failed to connect to the server.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Mengirim email verifikasi ke pengguna
  Future<void> _sendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/send-verification-email"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog(
            "Regristrasi Berhasil, Cek Email Anda untuk verifikasi.");
      } else {
        _showErrorDialog("gagal mengirim email");
      }
    } catch (_) {
      _showErrorDialog("Failed to connect to the server.");
    }
  }

// Menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.circleAlert, // Circle warning dari Lucide Icons
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  "Perhatian!",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
          ],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("OK", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

// Menampilkan dialog sukses
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.circleCheck, // Circle check dari Lucide Icons
                  color: Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  "Success",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
          ],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("OK", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // UI untuk tampilan form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF2567E8), Color(0xFF1CE6DA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8.0)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Register",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen())),
                        child: const Text("Log In",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF00509D),
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Username", _usernameController),
                  _buildTextField("Email", _emailController,
                      keyboardType: TextInputType.emailAddress),
                  _buildPasswordField("Password", _passwordController,
                      obscureText: _obscureText,
                      onToggle: () =>
                          setState(() => _obscureText = !_obscureText)),
                  _buildPasswordField(
                      "Confirm Password", _confirmPasswordController,
                      obscureText: _obscureTexts,
                      onToggle: () =>
                          setState(() => _obscureTexts = !_obscureTexts)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verifikasi",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: _inputDecoration()),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      {required bool obscureText, required VoidCallback onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: _inputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: onToggle)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  InputDecoration _inputDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      suffixIcon: suffixIcon,
    );
  }
}
