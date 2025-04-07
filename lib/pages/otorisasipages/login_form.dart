import 'package:aplikasi_scan_barang/main.dart';
import 'package:aplikasi_scan_barang/pages/otorisasipages/forgot_password.dart';
import 'package:aplikasi_scan_barang/pages/otorisasipages/register.dart';
import 'package:flutter/material.dart';
import 'login_form_logic.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final LoginFormLogic _logic = LoginFormLogic();

  @override
  void initState() {
    super.initState();
    _logic.loadCredentials();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 8.0, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField("Email", false, _logic.emailController),
          const SizedBox(height: 8),
          _buildTextField("Password", true, _logic.passwordController),
          const SizedBox(height: 8),
          _buildOptions(),
          const SizedBox(height: 16),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildRegisterRow(),
          const SizedBox(height: 16),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, bool isPassword, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword ? _logic.obscureText : false,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_logic.obscureText
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _logic.togglePasswordVisibility();
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _logic.rememberMe,
              onChanged: (value) {
                setState(() {
                  _logic.toggleRememberMe(value);
                });
              },
            ),
            const Text("Ingat Saya"),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage())),
          child: const Text("Lupa Password?"),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _logic.isLoading
          ? null
          : () async {
              setState(() {}); // Trigger rebuild for loading state
              final success = await _logic.loginUser(context);
              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: _logic.isLoading
          ? const CircularProgressIndicator()
          : const Text("Log In",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("Belum Punya Akun?",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterScreen())),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF1CE6DA),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: const Text("Registrasi",
          style: TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.w700)),
    );
  }
}
