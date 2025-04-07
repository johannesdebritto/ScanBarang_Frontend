import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '/pages/otorisasipages/login.dart';

class RegisterLogic {
  final BuildContext context;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  bool isLoading;

  RegisterLogic({
    required this.context,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.isLoading = false,
  });

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showErrorDialog("Semua Fied Harus Keisi");
      return;
    }

    if (password != confirmPassword) {
      showErrorDialog("Passwords do not match.");
      return;
    }

    isLoading = true;
    notifyState();

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        await sendVerificationEmail(email);
      } else {
        showErrorDialog(
            jsonDecode(response.body)['error'] ?? "An error occurred.");
      }
    } catch (_) {
      showErrorDialog("Failed to connect to the server.");
    } finally {
      isLoading = false;
      notifyState();
    }
  }

  Future<void> sendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/auth/send-verification-email"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        showSuccessDialog(
            "Regristrasi Berhasil, Cek Email Anda untuk verifikasi.");
      } else {
        showErrorDialog("gagal mengirim email");
      }
    } catch (_) {
      showErrorDialog("Failed to connect to the server.");
    }
  }

  void showErrorDialog(String message) {
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
                  LucideIcons.circleAlert,
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

  void showSuccessDialog(String message) {
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
                  LucideIcons.circleCheck,
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

  void notifyState() {
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }
}
