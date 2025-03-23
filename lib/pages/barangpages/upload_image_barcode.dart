import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadBarcodeScreen extends StatefulWidget {
  final Function(File?) onImagePicked;
  final String? initialBarcodeUrl; // ✅ Tambahan untuk URL barcode awal

  const UploadBarcodeScreen({
    super.key,
    required this.onImagePicked,
    this.initialBarcodeUrl,
  });

  @override
  State<UploadBarcodeScreen> createState() => _UploadBarcodeScreenState();
}

class _UploadBarcodeScreenState extends State<UploadBarcodeScreen> {
  File? _barcodeImage;
  String? _displayBarcodeUrl;

  @override
  void initState() {
    super.initState();
    _displayBarcodeUrl = widget.initialBarcodeUrl;
  }

  Future<void> _pickBarcodeImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _barcodeImage = File(pickedFile.path);
        _displayBarcodeUrl = null; // Hapus URL jika user pilih barcode baru
      });
      widget.onImagePicked(_barcodeImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Upload Barcode Gambar",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _pickBarcodeImage,
          child: Container(
            width: 300,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3a0ca3), width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: _barcodeImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _barcodeImage!,
                      width: 300,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                : _displayBarcodeUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _displayBarcodeUrl!,
                          width: 300,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.qr_code, size: 40, color: Colors.black54),
                          SizedBox(height: 5),
                          Text(
                            "Pilih Barcode Gambar",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 8),
        if (_barcodeImage != null || _displayBarcodeUrl != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 5),
                Text(
                  "Barcode berhasil di-upload",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
