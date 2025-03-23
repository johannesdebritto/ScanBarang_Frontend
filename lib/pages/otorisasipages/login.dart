import 'package:aplikasi_scan_barang/pages/otorisasipages/login_form.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2567E8), Color(0xFF1CE6DA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: LoginFormScreen(),
          ),
        ),
      ),
    );
  }
}
