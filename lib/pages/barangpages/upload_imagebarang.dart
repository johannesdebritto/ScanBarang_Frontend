import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'image_picker_options.dart'; // Import the new file

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

  Text _poppinsText(String text, double size, FontWeight weight, Color color) {
    return Text(
      text,
      style:
          GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color),
    );
  }

  Future<void> _showImagePickerOptions() async {
    await ImagePickerOptions.show(
      context: context,
      onSourceSelected: _pickImage,
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
    // Hapus atau biarkan tanpa Navigator.pop(context)
  }

  Widget _imagePreview() {
    final borderRadius = BorderRadius.circular(16);
    Widget? imageWidget;

    if (_image != null) {
      imageWidget = Image.file(_image!, fit: BoxFit.cover);
    } else if (_displayImageUrl != null) {
      imageWidget = Image.network(_displayImageUrl!, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          color: Colors.grey[50],
        ),
        child: imageWidget != null
            ? ClipRRect(borderRadius: borderRadius, child: imageWidget)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C56F5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined,
                        size: 40, color: Color(0xFF6C56F5)),
                  ),
                  const SizedBox(height: 16),
                  _poppinsText("Upload Product Image", 16, FontWeight.w500,
                      Colors.black87),
                  const SizedBox(height: 8),
                  _poppinsText("Recommended size: 800x800px", 12,
                      FontWeight.normal, Colors.grey),
                ],
              ),
      ),
    );
  }

  Widget _successMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          _poppinsText("Image uploaded successfully", 14, FontWeight.w500,
              const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _image != null || _displayImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _poppinsText("Product Image", 16, FontWeight.w600, Colors.black87),
        const SizedBox(height: 12),
        _imagePreview(),
        if (hasImage) ...[
          const SizedBox(height: 12),
          _successMessage(),
        ],
      ],
    );
  }
}
