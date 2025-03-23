import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UploadImageWidget extends StatefulWidget {
  final Function(File?) onImagePicked;
  final String? initialImageUrl;

  const UploadImageWidget({
    super.key,
    required this.onImagePicked,
    this.initialImageUrl,
  });

  @override
  State<UploadImageWidget> createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  File? _image;
  String? _displayImageUrl;

  @override
  void initState() {
    super.initState();
    _displayImageUrl = widget.initialImageUrl;
  }

  Future<void> _showImagePickerOptions() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pilih Sumber Gambar",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOptionButton(
                      assetPath: 'assets/foto.svg',
                      label: "Kamera",
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildOptionButton(
                      assetPath: 'assets/galeri.svg',
                      label: "Galeri",
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBackButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required String assetPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: SvgPicture.asset(
        assetPath,
        height: 24,
        width: 24,
      ),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        side: const BorderSide(color: Colors.black54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        "Kembali",
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7F56D9),
        elevation: 3,
        shadowColor: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _displayImageUrl = null;
      });
      widget.onImagePicked(_image);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Upload Gambar Barang",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            width: 300,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3a0ca3), width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_image!,
                        width: 300, height: 180, fit: BoxFit.cover),
                  )
                : _displayImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_displayImageUrl!,
                            width: 300, height: 180, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image,
                              size: 40, color: Colors.black54),
                          const SizedBox(height: 5),
                          Text("Pilih Gambar/Foto",
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.black54)),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 8),
        if (_image != null || _displayImageUrl != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text(
                  "Gambar berhasil di-upload",
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
