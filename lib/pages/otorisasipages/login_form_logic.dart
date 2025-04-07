import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class LoginFormLogic {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;
  bool rememberMe = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      emailController.text = email;
      passwordController.text = password;
      rememberMe = true;
    }
  }

  Future<bool> loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "Email dan password tidak boleh kosong.");
      return false;
    }

    isLoading = true;

    try {
      print("🔵 Mengirim permintaan login ke backend...");
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print("🟢 Login ke backend berhasil!");

        final responseData = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // Simpan email dan password jika rememberMe dipilih
        if (rememberMe) {
          await prefs.setString('email', email);
          await prefs.setString('password', password);
        } else {
          await prefs.remove('email');
          await prefs.remove('password');
        }

        // Simpan username dari backend
        if (responseData['username'] != null) {
          await prefs.setString('username', responseData['username']);
          print("🟢 Username berhasil disimpan: ${responseData['username']}");
        }

        // Login ke Firebase Auth
        print("🔵 Login ke Firebase Auth...");
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final firebaseUser = _auth.currentUser;
        if (firebaseUser == null) {
          throw Exception("Gagal mendapatkan user dari Firebase.");
        }

        String? token = await firebaseUser.getIdToken();
        if (token != null) {
          await prefs.setString('firebase_token', token);
          print("🟢 Token Firebase berhasil didapatkan!");
        } else {
          throw Exception("Gagal mendapatkan token Firebase.");
        }

        return true;
      } else {
        print("🔴 Login gagal dengan status: ${response.statusCode}");
        _handleError(context, response.statusCode);
        return false;
      }
    } catch (e) {
      print("🔴 Gagal terhubung ke server: $e");
      _showErrorDialog(context, "Gagal terhubung ke server.");
      return false;
    } finally {
      isLoading = false;
    }
  }

  void _handleError(BuildContext context, int statusCode) {
    switch (statusCode) {
      case 404:
        _showErrorDialog(context, "Email Anda belum terdaftar.");
        break;
      case 401:
        _showErrorDialog(context, "Password Anda salah.");
        break;
      default:
        _showErrorDialog(context, "Terjadi kesalahan. Silakan coba lagi.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.circleAlert,
                    color: Colors.orange, size: 32),
                const SizedBox(width: 10),
                const Text(
                  "Perhatian!",
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("OK", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void togglePasswordVisibility() {
    obscureText = !obscureText;
  }

  void toggleRememberMe(bool? value) {
    if (value != null) {
      rememberMe = value;
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
