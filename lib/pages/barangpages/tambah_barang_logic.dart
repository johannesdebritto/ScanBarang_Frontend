import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:aplikasi_scan_barang/main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class TambahBarangLogic {
  final BuildContext context;
  bool isUploading = false;
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  TambahBarangLogic(this.context);

  Future<void> uploadData({
    required Map<String, dynamic> formData,
    required bool isEdit,
    File? selectedImage,
    String? itemId,
  }) async {
    try {
      print('📤 [Upload Barang] Mulai proses upload...');
      final token = await _getFirebaseToken();
      if (token == null) return;

      final uploadUri = _getUploadUri(isEdit, itemId);
      final request = _createMultipartRequest(uploadUri, token, isEdit);

      File? qrCodeFile;
      if (!isEdit) {
        final qrData = {
          'name': formData['name'],
          'quantity': formData['quantity'],
          'brand': formData['brand'],
          'code': formData['code'],
          'image_url': selectedImage != null ? selectedImage.path : null,
        };
        final qrDataString = jsonEncode(qrData);

        qrCodeFile = await _generateHighQualityQRCode(qrDataString);
        if (qrCodeFile == null) {
          throw Exception("Gagal membuat QR Code");
        }
      }

      if (qrCodeFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'qr_code_image',
            qrCodeFile.path,
            contentType: MediaType('image', 'png'),
          ),
        );
        print('🖨️ [Upload Barang] QR Code ditambahkan ke request');
        print('📍 Path QR Code: ${qrCodeFile.path}');
      }

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            selectedImage.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        print('🖼️ [Upload Barang] Gambar barang ditambahkan ke request');
      }

      _addFormFields(request, formData);

      final response = await request.send();
      await _handleResponse(response, isEdit);
    } catch (e) {
      print("❌ [Upload Barang] Error: $e");
      showWarningDialog('Gagal upload barang: ${e.toString()}');
      rethrow;
    }
  }

  Future<String?> _getFirebaseToken() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        showWarningDialog('Gagal mendapatkan token. Coba login ulang!');
        print('❌ [Upload Barang] Gagal mendapatkan token Firebase!');
        return null;
      }
      print('🔑 [Upload Barang] Token Firebase berhasil didapatkan');
      return token;
    } catch (e) {
      print('❌ [Upload Barang] Error mendapatkan token: $e');
      return null;
    }
  }

  Uri _getUploadUri(bool isEdit, String? itemId) {
    return isEdit
        ? Uri.parse('$baseUrl/api/barang/$itemId')
        : Uri.parse('$baseUrl/api/barang');
  }

  http.MultipartRequest _createMultipartRequest(
      Uri uploadUri, String token, bool isEdit) {
    final request = http.MultipartRequest(
      isEdit ? 'PUT' : 'POST',
      uploadUri,
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    return request;
  }

  Future<File?> _generateHighQualityQRCode(String qrCodeData) async {
    try {
      if (qrCodeData.isEmpty) {
        print('⚠️ Data QR Code kosong!');
        return null;
      }
      print('🔠 Data QR Code: $qrCodeData');

      final qrPainter = QrPainter(
        data: qrCodeData,
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      const double qrSize = 800.0;
      const double padding = 100.0;
      const double totalSize = qrSize + (padding * 2);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromPoints(Offset(0, 0), Offset(totalSize, totalSize)),
      );

      final paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), paint);
      canvas.translate(padding, padding);

      qrPainter.paint(
        canvas,
        Size(qrSize, qrSize),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(totalSize.toInt(), totalSize.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('❌ Gagal mengubah QR ke byte data');
        return null;
      }

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!await file.exists()) {
        print('❌ File QR Code tidak terbuat');
        return null;
      }

      print(
          '✅ QR Code berhasil dibuat! Ukuran file: ${file.lengthSync()} bytes');
      return file;
    } catch (e) {
      print('❌ Error saat membuat QR Code: $e');
      return null;
    }
  }

  void _addFormFields(
      http.MultipartRequest request, Map<String, dynamic> formData) {
    request.fields['name'] = formData['name'];
    request.fields['quantity'] = formData['quantity'].toString();
    request.fields['code'] = formData['code'];
    request.fields['brand'] = formData['brand'];
    print('📝 [Upload Barang] Data form berhasil disiapkan');
  }

  Future<void> _handleResponse(
      http.StreamedResponse response, bool isEdit) async {
    final responseBody = await response.stream.bytesToString();
    print('📡 Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ [Upload Barang] Barang berhasil diupload!');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Barang berhasil diperbarui!'
              : 'Barang berhasil disimpan!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MainScreen(selectedIndex: 1)),
        (Route<dynamic> route) => false,
      );
    } else {
      print('❌ [Upload Barang] Gagal upload! Status: ${response.statusCode}');
      throw Exception(
          "Gagal ${isEdit ? 'memperbarui' : 'menyimpan'} barang! Status: ${response.statusCode}");
    }
  }

  void showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
