import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class BerandaLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getUserToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<List<dynamic>> fetchEvents() async {
    final token = await _getUserToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/api/event/tampil'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal mengambil data event: ${response.statusCode}");
    }
  }

  Future<bool> deleteEvent(String idEvent, BuildContext context) async {
    final token = await _getUserToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/api/event/hapus/$idEvent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Menampilkan SnackBar dengan background hijau dan icon centang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green), // Icon centang hijau
              const SizedBox(width: 8),
              const Text("Event berhasil dihapus"),
            ],
          ),
          backgroundColor: Colors.green, // Background hijau
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.red), // Icon error merah
              const SizedBox(width: 8),
              Text("Gagal menghapus event: ${response.body}"),
            ],
          ),
          backgroundColor: Colors.red, // Background merah
        ),
      );
      return false;
    }
  }
}
