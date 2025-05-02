import 'dart:convert';
import 'package:aplikasi_scan_barang/main.dart';
import 'package:aplikasi_scan_barang/pages/berandapages/detail_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannerScreenLogic {
  final BuildContext context;
  final String idEvent; // Tetap gunakan String untuk fleksibilitas

  ScannerScreenLogic(
      this.context, this.idEvent); // Parameter idEvent tetap String

  bool isDialogOpen = false;
  String? scannedData;

  Future<String?> getToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (e) {
      print("❌ Gagal mendapatkan token: $e");
      return null;
    }
  }

  Future<void> sendScanResult(String qrCode) async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      print("❌ BASE_URL tidak ditemukan di .env");
      return;
    }

    String? token = await getToken();
    if (token == null) {
      showMessageDialog("❌ Error", "Token tidak valid, silakan login ulang.");
      return;
    }

    final String url = "$baseUrl/api/event/scan";
    print("📤 Mengirim request ke: $url");
    print("📌 Data yang dikirim: { 'qr_code': '$qrCode' }");

    // Tampilkan loading modal
    showLoadingDialog();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qr_code': qrCode}),
      );

      print("🔵 Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      String message;
      if (response.statusCode == 201) {
        message = "✅ QR Code berhasil disimpan!";
      } else if (response.statusCode == 409) {
        message = "⚠️ QR Code ini sudah digunakan!";
      } else if (response.statusCode == 403) {
        message = "❌ Token tidak valid, silakan login ulang.";
      } else {
        message = "❌ Terjadi kesalahan: ${response.body}";
      }

      // Tutup loading modal
      closeDialog();

      // Tampilkan pesan ke user
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      // Jika sukses, cukup tutup modal tanpa keluar dari halaman
      if (response.statusCode == 201) {
        startScanner(); // 🔥 Kamera aktif kembali untuk scan
      }
    } catch (e) {
      closeDialog();
      print("❌ Gagal menghubungi server: $e");
      showMessageDialog(
          "❌ Error", "Tidak bisa menghubungi server, coba lagi nanti.");
    }
  }

/////////////////////////////////////////////////////////////////////////////////

  void showResultDialog(String result, bool isSelesai) {
    String title = isSelesai ? "Barang Selesai" : "Hasil Scan";
    String buttonText = isSelesai ? "Selesai" : "Simpan";
    String displayText;

    final Map<String, String> icons = {
      'nama': '📦',
      'quantity': '🔢',
      'code': '🆔',
      'brand': '🏷️',
      'image': '🖼️', // Placeholder untuk image
    };

    try {
      final decoded = jsonDecode(result);
      if (decoded is Map<String, dynamic>) {
        displayText = decoded.entries.map((e) {
          final keyLower = e.key.toLowerCase();
          final icon = icons.containsKey(keyLower) ? icons[keyLower]! : '🔹';
          final label = _capitalize(e.key).padRight(8);
          return "$icon $label: ${e.value}";
        }).join("\n");
      } else {
        displayText = result;
      }
    } catch (e) {
      displayText = result;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 16),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'inter',
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                dialogButton("Batal", Colors.red, closeDialog),
                SizedBox(width: 8),
                dialogButton(buttonText, Colors.green, () async {
                  closeDialog();
                  if (isSelesai) {
                    if (idEvent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("❌ ID Event tidak valid: ID kosong")),
                      );
                      return;
                    }
                    await completeQRCode(result, idEvent, context);
                  } else {
                    await sendScanResult(result);
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String input) {
    return input.isEmpty ? input : input[0].toUpperCase() + input.substring(1);
  }

  //////////////////////////////////////////////////////////////////////////////

  Widget dialogButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  void showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // 🔥 Teks judul di tengah
            ),
            Divider(color: Colors.grey[300], thickness: 1), // 🔥 Garis pemisah
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center, // 🔥 Teks isi di tengah
        ),
        actions: [
          Center(
            // 🔥 Tombol di tengah
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // 🔥 Tombol hijau
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 🔥 Teks putih
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void closeDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
      isDialogOpen = false;
      scannedData = null;
    }
  }

  // 🔥 Loading Modal (Fix tanpa garis kuning dan bisa ditutup)
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Menyimpan QR Barang...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 Fungsi untuk mengaktifkan scanner kembali setelah simpan berhasil
  void startScanner() {
    print("📸 Scanner aktif kembali...");
  }

//loadingsimpan
// 🔥 Loading Modal saat mengecek QR Code sebelum keluar halaman
  void showLoadingDialogSimpan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Mengecek Data...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void closeScannerScreen({String? idEvent, bool isSelesai = false}) async {
    print(
        "📌 closeScannerScreen dipanggil dengan idEvent: $idEvent, isSelesai: $isSelesai");

    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      print("❌ BASE_URL tidak ditemukan di .env");
      return;
    }

    String? token = await getToken();
    if (token == null) {
      showMessageDialog("❌ Error", "Token tidak valid, silakan login ulang.");
      return;
    }

    final String url = "$baseUrl/api/event/check-qrcode";
    print("📤 Mengecek QR di event dengan request ke: $url");

    // Tampilkan loading sebelum pengecekan
    showLoadingDialogSimpan();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔵 Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      closeDialog();

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['exists'] == true) {
        print(
            "📌 idEvent saat closeScannerScreen dipanggil: $idEvent, isSelesai: $isSelesai");

        if (idEvent != null && idEvent.trim().isNotEmpty) {
          if (isSelesai == true) {
            print("✅ Navigasi ke DetailEventScreen SELESAI: $idEvent");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailEventScreen(idEvent: idEvent, isSelesai: true),
              ),
            );
          } else {
            print("✅ Navigasi ke DetailEventScreen BIASA: $idEvent");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DetailEventScreen(idEvent: idEvent),
              ),
            );
          }
        } else {
          print("🔄 idEvent kosong, kembali ke Beranda");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(selectedIndex: 0)),
            (route) => false,
          );
        }
      } else {
        showMessageDialog("⚠️ Peringatan", "Belum ada barang yang di-scan!");
      }
    } catch (e) {
      closeDialog();
      print("❌ Gagal menghubungi server: $e");
      showMessageDialog(
          "❌ Error", "Tidak bisa menghubungi server, coba lagi nanti.");
    }
  }

  Future<void> completeQRCode(
      String qrCode, String idEvent, BuildContext context) async {
    // Ganti int menjadi String
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      print("❌ BASE_URL tidak ditemukan di .env");
      return;
    }

    String? token = await getToken();
    if (token == null) {
      showMessageDialog("❌ Error", "Token tidak valid, silakan login ulang.");
      return;
    }

    final String url = "$baseUrl/api/event/scan-complete";
    print("📤 Mengirim request ke: $url");
    print(
        "📌 Data yang dikirim: { 'qr_code': '$qrCode', 'id_event': '$idEvent' }");

    showLoadingDialog();

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'qr_code': qrCode,
          'id_event': idEvent // idEvent tetap dalam format String
        }),
      );

      closeDialog();
      print("🔵 Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      String message;
      if (response.statusCode == 200) {
        message = "✅ QR Code berhasil diselesaikan!";
      } else if (response.statusCode == 404) {
        message = "⚠️ Event atau QR Code tidak ditemukan.";
      } else if (response.statusCode == 401) {
        message = "❌ Token tidak valid, silakan login ulang.";
      } else {
        message = "❌ Terjadi kesalahan: ${response.body}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      if (response.statusCode == 200) {
        showMessageDialog("Selesai", "QR Code telah berhasil diselesaikan!");
        startScanner();
      }
    } catch (e) {
      closeDialog();
      print("❌ Gagal menghubungi server: $e");
      showMessageDialog(
          "❌ Error", "Tidak bisa menghubungi server, coba lagi nanti.");
    }
  }
}
