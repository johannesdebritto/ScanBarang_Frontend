import 'package:aplikasi_scan_barang/pages/otorisasipages/login.dart';
import 'package:flutter/material.dart';

import 'register_logic.dart';

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
  bool _obscureText = true, _obscureTexts = true;
  late RegisterLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = RegisterLogic(
      context: context,
      usernameController: _usernameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
    );
  }

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
                    onPressed: _logic.isLoading ? null : _logic.registerUser,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                    child: _logic.isLoading
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
