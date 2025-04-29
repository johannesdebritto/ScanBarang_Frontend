import 'dart:io';
import 'package:aplikasi_scan_barang/pages/barangpages/form_barang.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/form_logic.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/tambah_barang_logic.dart';
import 'package:flutter/material.dart';

import 'upload_imagebarang.dart';

class TambahBarangScreen extends StatefulWidget {
  final dynamic itemData;
  const TambahBarangScreen({Key? key, this.itemData}) : super(key: key);

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  File? _selectedImage;
  late final _formLogic = FormBarangLogic();
  late final _logic = TambahBarangLogic(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.itemData != null) {
        print("🟢 Item data received: ${widget.itemData}");
        _formLogic.setInitialData(widget.itemData); // Set data to form
      }
    });
  }

  Future<void> _uploadData() async {
    final formData = _formLogic.getFormData();

    // Debug log to verify form data
    print("🔵 Form data to be uploaded: $formData");

    if (formData == null) {
      _logic.showWarningDialog('Isi semua field formulir!');
      return;
    }

    if (_selectedImage == null && widget.itemData == null) {
      _logic.showWarningDialog('Pilih gambar terlebih dahulu!');
      return;
    }

    setState(() => _logic.isUploading = true);

    try {
      await _logic.uploadData(
        formData: formData,
        selectedImage: _selectedImage,
        isEdit: widget.itemData != null,
        itemId: widget.itemData?['id']?.toString(), // Pastikan ID adalah String
      );
    } catch (e) {
      _logic.showWarningDialog('Error: $e');
    } finally {
      if (mounted) setState(() => _logic.isUploading = false);
    }
  }

  @override
  void dispose() {
    _formLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.itemData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0052AB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UploadImageWidget(
                    onImagePicked: (image) =>
                        setState(() => _selectedImage = image),
                    initialImageUrl: isEditMode &&
                            widget.itemData != null &&
                            widget.itemData['image_url'] != null
                        ? '${_logic.baseUrl}/images/${widget.itemData['image_url']}'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FormBarangScreen(formLogic: _formLogic),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _logic.isUploading ? null : _uploadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3a0ca3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: _logic.isUploading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
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
