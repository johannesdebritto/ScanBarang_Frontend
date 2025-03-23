import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannerScreenLogic {
  final BuildContext context;

  ScannerScreenLogic(this.context);

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

    // Tutup dialog
    closeDialog();

    // Tampilkan pesan
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner,
                      color: const Color.fromARGB(255, 9, 9, 9)),
                  SizedBox(width: 8),
                  Text(
                    "Hasil Scan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 16),
            Text(result, style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                dialogButton("Batal", Colors.red, closeDialog),
                SizedBox(width: 8),
                dialogButton("Simpan", Colors.green, () async {
                  await sendScanResult(result);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK", style: TextStyle(fontSize: 14)),
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
}
