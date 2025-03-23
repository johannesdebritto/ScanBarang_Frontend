import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class EventFormLogic {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _namaEventController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  TextEditingController get tanggalController => _tanggalController;
  TextEditingController get namaEventController => _namaEventController;
  TextEditingController get cityController => _cityController;
  TextEditingController get provinceController => _provinceController;

  Future<bool> simpanEvent(BuildContext context) async {
    print("🔍 Debug: Fungsi simpanEvent() dipanggil");

    final String namaEvent = _namaEventController.text;
    final String tanggal = _tanggalController.text;
    final String kota = _cityController.text;
    final String kabupaten = _provinceController.text;

    if (namaEvent.isEmpty ||
        tanggal.isEmpty ||
        kota.isEmpty ||
        kabupaten.isEmpty) {
      print("⚠️ Debug: Ada field yang kosong!");
      _showSnackbar(
          context, "Semua field harus diisi!", Colors.red, Icons.error);
      return false;
    }

    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      print("🚨 Debug: Token tidak ditemukan!");
      _showSnackbar(context, "Gagal mendapatkan token. Coba login ulang!",
          Colors.red, Icons.error);
      return false;
    }

    final Map<String, dynamic> eventData = {
      "nama_event": namaEvent,
      "tanggal": tanggal,
      "kota": kota,
      "kabupaten": kabupaten,
    };

    print("📤 Debug: Data yang dikirim: $eventData");

    // 🚀 Tampilkan modal loading sebelum request
    _showLoadingDialog(context);

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BASE_URL']}/api/event/simpan"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(eventData),
      );

      print("🛜 Debug: Status code: ${response.statusCode}");
      print("🔹 Debug: Response body: ${response.body}");

      // ❌ Tutup modal setelah request selesai
      Navigator.pop(context);

      if (response.statusCode == 201) {
        print("✅ Debug: Event berhasil disimpan!");
        _showSnackbar(context, "Event berhasil disimpan!", Colors.green,
            LucideIcons.circleCheck);
        return true;
      } else {
        print("❌ Debug: Gagal menyimpan event: ${response.body}");
        _showSnackbar(context, "Gagal menyimpan event: ${response.body}",
            Colors.red, Icons.error);
        return false;
      }
    } catch (error) {
      // ❌ Tutup modal jika terjadi error
      Navigator.pop(context);
      print("🚨 Debug: Terjadi error: $error");
      _showSnackbar(
          context, "Terjadi kesalahan: $error", Colors.red, Icons.error);
      return false;
    }
  }

  // 🔥 Fungsi untuk menampilkan loading modal dengan warna biru
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup sebelum selesai
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Background redup
            Opacity(
              opacity: 0.5,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
            // Tulisan loading di tengah dengan warna biru
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7), // Warna biru transparan
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Menyimpan data event...",
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔥 Fungsi Snackbar Custom dengan Google Fonts
  void _showSnackbar(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
