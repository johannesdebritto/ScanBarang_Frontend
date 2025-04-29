import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerOptions {
  static Text _poppinsText(
      String text, double size, FontWeight weight, Color color) {
    return Text(
      text,
      style:
          GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color),
    );
  }

  static Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          _poppinsText(label, 14, FontWeight.w500, Colors.black87),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required Function(ImageSource) onSourceSelected,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _poppinsText(
                  "Select Image Source", 18, FontWeight.w600, Colors.black87),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: const Color(0xFF6C56F5),
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: Colors.grey[200]),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: _poppinsText(
                    "Cancel", 16, FontWeight.w500, Colors.red[400]!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
