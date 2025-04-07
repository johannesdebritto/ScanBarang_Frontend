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

  Future<bool> simpanAtauEditEvent(BuildContext context, {int? eventId}) async {
    print("🔍 Debug: Fungsi simpanAtauEditEvent() dipanggil");

    final String namaEvent = _namaEventController.text;
    final String inputTanggal = _tanggalController.text;
    final String kota = _cityController.text;
    final String kabupaten = _provinceController.text;

    if (namaEvent.isEmpty ||
        inputTanggal.isEmpty ||
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
      "tanggal": inputTanggal, // ⬅️ Tidak dikonversi, langsung dikirim
      "kota": kota,
      "kabupaten": kabupaten,
    };

    print("📤 Debug: Data yang dikirim: $eventData");

    _showLoadingDialog(context);

    try {
      final Uri url = eventId == null
          ? Uri.parse("${dotenv.env['BASE_URL']}/api/event/simpan")
          : Uri.parse("${dotenv.env['BASE_URL']}/api/event/update/$eventId");

      final response = eventId == null
          ? await http.post(
              url,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(eventData),
            )
          : await http.put(
              url,
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode(eventData),
            );

      print("🛜 Debug: Status code: ${response.statusCode}");
      print("🔹 Debug: Response body: ${response.body}");

      Navigator.pop(context);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(
            "✅ Debug: Event berhasil ${eventId == null ? "disimpan" : "diedit"}!");
        _showSnackbar(
            context,
            "Event berhasil ${eventId == null ? "disimpan" : "diedit"}!",
            Colors.green,
            LucideIcons.circleCheck);
        return true;
      } else {
        print("❌ Debug: Gagal menyimpan event: ${response.body}");
        _showSnackbar(context, "Gagal menyimpan event: ${response.body}",
            Colors.red, Icons.error);
        return false;
      }
    } catch (error) {
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

//load
  Future<void> loadEvent(int eventId) async {
    print("🔍 Debug: Memuat event dengan ID $eventId");

    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      print("🚨 Debug: Token tidak ditemukan!");
      return;
    }

    final Uri url =
        Uri.parse("${dotenv.env['BASE_URL']}/api/event/ambil-edit/$eventId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("🛜 Debug: Response status: ${response.statusCode}");
      print("📥 Debug: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Debug: Data event berhasil dimuat: $data");

        // Fungsi untuk format tanggal dari ISO 8601 ke DD-MM-YYYY
        String formatTanggal(String isoDate) {
          DateTime date = DateTime.parse(isoDate);
          return "${date.day.toString().padLeft(2, '0')}-"
              "${date.month.toString().padLeft(2, '0')}-"
              "${date.year}";
        }

        _namaEventController.text = data['nama_event'] ?? '';

        // Ubah format tanggal sebelum masuk ke controller
        _tanggalController.text =
            data['tanggal'] != null ? formatTanggal(data['tanggal']) : '';

        _cityController.text = data['kota'] ?? '';
        _provinceController.text = data['kabupaten'] ?? '';

        print("📌 Debug: Nama Event: ${_namaEventController.text}");
        print("📌 Debug: Tanggal Event: ${_tanggalController.text}");
        print("📌 Debug: Kota: ${_cityController.text}");
        print("📌 Debug: Kabupaten: ${_provinceController.text}");
      } else {
        print("❌ Debug: Gagal memuat event: ${response.body}");
      }
    } catch (error) {
      print("🚨 Debug: Terjadi kesalahan saat memuat event: $error");
    }
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
