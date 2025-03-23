import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aplikasi_scan_barang/pages/otorisasipages/login.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isLoggingOut = false; // State untuk indikator logout

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true; // Tampilkan indikator loading
    });

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/api/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint("Terjadi kesalahan saat logout: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut =
              false; // Sembunyikan indikator loading setelah selesai
        });
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            "Apakah Anda yakin ingin logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout();
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(16),
        top: Radius.circular(16),
      ),
      child: AppBar(
        backgroundColor: const Color(0xFF3a0ca3),
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(widget.icon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          _isLoggingOut
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _showLogoutConfirmation,
                ),
        ],
      ),
    );
  }
}
