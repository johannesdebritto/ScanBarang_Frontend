import 'package:aplikasi_scan_barang/pages/otorisasipages/forgot_password.dart';
import 'package:aplikasi_scan_barang/pages/otorisasipages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/main.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    setState(() {
      if (email != null && password != null) {
        _emailController.text = email;
        _passwordController.text = password;
        _rememberMe = true;
      }
    });
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Email dan password tidak boleh kosong.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🔵 Mengirim permintaan login ke backend...");
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print("🟢 Login ke backend berhasil!");

        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('email', email);
          await prefs.setString('password', password);
        } else {
          await prefs.remove('email');
          await prefs.remove('password');
        }

        // 🔥 Login ke Firebase Auth setelah login backend sukses
        print("🔵 Login ke Firebase Auth...");
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          throw Exception("Gagal mendapatkan user dari Firebase.");
        }

        print("🟢 Login ke Firebase berhasil! UID: ${firebaseUser.uid}");

        // 🔥 Ambil token Firebase dan simpan di SharedPreferences
        String? token = await firebaseUser.getIdToken();
        if (token != null) {
          await prefs.setString('firebase_token', token);
          print("🟢 Token Firebase berhasil didapatkan!");
          print("🟢 Firebase ID Token: $token"); // 🔥 Print Token Firebase
        } else {
          throw Exception("Gagal mendapatkan token Firebase.");
        }

        // Pindah ke halaman utama setelah login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        print("🔴 Login gagal dengan status: ${response.statusCode}");
        _handleError(response.statusCode);
      }
    } catch (e) {
      print("🔴 Gagal terhubung ke server: $e");
      _showErrorDialog("Gagal terhubung ke server.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleError(int statusCode) {
    switch (statusCode) {
      case 404:
        _showErrorDialog("Email Anda belum terdaftar.");
        break;
      case 401:
        _showErrorDialog("Password Anda salah.");
        break;
      default:
        _showErrorDialog("Terjadi kesalahan. Silakan coba lagi.");
    }
  }

// modal login
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
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
          _buildTextField("Email", false, _emailController),
          const SizedBox(height: 8),
          _buildTextField("Password", true, _passwordController),
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

  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value!),
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
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _loginUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text("Log In",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
    );
  }
}
