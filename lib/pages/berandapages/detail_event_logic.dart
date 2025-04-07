import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailEventLogic {
  final String idEvent;

  DetailEventLogic({required this.idEvent});

  Future<Map<String, dynamic>?> fetchEventDetail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/api/event/detail/$idEvent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Gagal mengambil detail event: ${response.body}");
      return null;
    }
  }

  Future<List<dynamic>> fetchQRCodeList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '${dotenv.env['BASE_URL']}/api/event/tampil_scan?id_event=$idEvent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      print("❌ Gagal mengambil daftar QR Code: ${response.body}");
      return [];
    }
  }

  Future<bool> deleteQRCode(String qrCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/api/event/hapus-scan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({"qr_code": qrCode}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Gagal menghapus QR Code: ${response.body}");
      return false;
    }
  }

  Future<bool> completeEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final token = await user.getIdToken();
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/api/event/event-selesai'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_event": idEvent,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Gagal menyelesaikan event: ${response.body}");
      return false;
    }
  }

  String formatTanggal(String tanggal) {
    DateTime dateTime = DateTime.parse(tanggal);
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
