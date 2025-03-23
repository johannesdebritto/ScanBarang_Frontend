import 'dart:io';
import 'package:aplikasi_scan_barang/main.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/upload_image_barcode.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambah ini
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'upload_imagebarang.dart';
import 'form_barang.dart';
import 'package:icons_plus/icons_plus.dart';

class TambahBarangScreen extends StatefulWidget {
  final dynamic itemData;
  const TambahBarangScreen({Key? key, this.itemData}) : super(key: key);

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  File? _selectedImage;
  File? _selectedBarcode;
  bool _isUploading = false;
  final GlobalKey<FormBarangScreenState> _formKey =
      GlobalKey<FormBarangScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.itemData != null) {
        _loadItemData();
      }
    });
  }

  void _loadItemData() {
    _formKey.currentState?.setInitialData(widget.itemData);
  }

  void _onImagePicked(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _onBarcodePicked(File? barcode) {
    setState(() {
      _selectedBarcode = barcode;
    });
  }

  Future<void> _uploadData() async {
    final formData = _formKey.currentState?.getFormData();
    if (formData == null) {
      _showWarningDialog('Isi semua field formulir!');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 🔥 Ambil Firebase ID Token
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        _showWarningDialog('Gagal mendapatkan token. Coba login ulang!');
        return;
      }

      final isEdit = widget.itemData != null;
      final uploadUri = isEdit
          ? Uri.parse(
              '${dotenv.env['BASE_URL']}/api/barang/${widget.itemData['id']}')
          : Uri.parse('${dotenv.env['BASE_URL']}/api/barang');

      final request = http.MultipartRequest(isEdit ? 'PUT' : 'POST', uploadUri);

      // ✅ Tambahkan token ke headers
      request.headers['Authorization'] = 'Bearer $token';

      // ✅ Tambahkan gambar hanya jika ada yang baru diunggah
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      if (_selectedBarcode != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'barcodeImage',
            _selectedBarcode!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // ✅ Kirim data form ke backend
      request.fields['name'] = formData['name'];
      request.fields['quantity'] = formData['quantity'].toString();
      request.fields['code'] = formData['code'];
      request.fields['brand'] = formData['brand'];

      final response = await request.send();

      // ✅ Cek apakah berhasil atau gagal
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'Barang berhasil diperbarui!'
                : 'Barang berhasil disimpan!'),
          ),
        );
        // ✅ Kembali ke halaman utama setelah sukses
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(selectedIndex: 1),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        // ❌ Error dari server
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            "Gagal ${isEdit ? 'memperbarui' : 'menyimpan'} barang! Status: ${response.statusCode}, Response: $responseBody");
      }
    } catch (e) {
      print("❌ Error: $e");
      _showWarningDialog('Error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Oke",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.itemData != null;

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0052AB),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            padding:
                const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  isEditMode ? "Edit Barang" : "Tambah Barang",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UploadImageWidget(
                    onImagePicked: _onImagePicked,
                    initialImageUrl: isEditMode &&
                            widget.itemData['image_url'] != null
                        ? '${dotenv.env['BASE_URL']}/images/${widget.itemData['image_url']}'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  UploadBarcodeScreen(
                    onImagePicked: _onBarcodePicked,
                    initialBarcodeUrl: isEditMode &&
                            widget.itemData['barcode_image_url'] != null
                        ? '${dotenv.env['BASE_URL']}/barcodes/${widget.itemData['barcode_image_url']}'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FormBarangScreen(
                    key: _formKey,
                    initialData: isEditMode ? widget.itemData : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3a0ca3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Iconsax.save_add_outline,
                          color: Colors.white),
                      label: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditMode ? "Perbarui Data" : "Simpan Data",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
