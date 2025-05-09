import 'dart:io';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_scan_barang/widgets/delete_modal.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/tambah_barang_screen.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProductButtons extends StatelessWidget {
  final VoidCallback onDelete;
  final Map<String, dynamic> itemData;

  const ProductButtons({
    super.key,
    required this.onDelete,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButton(
              context,
              icon: Icons.edit_outlined,
              label: 'Edit',
              color: Colors.purple.shade900,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TambahBarangScreen(itemData: itemData),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              context,
              icon: Icons.delete_outline,
              label: 'Hapus',
              color: Colors.red.shade900,
              onTap: () {
                showDeleteConfirmationDialog(
                  context: context,
                  onDelete: onDelete,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.qr_code_2_outlined,
          label: 'Download QR',
          color: Colors.blue.shade900,
          onTap: () async {
            final qrPath = itemData['qr_code_url'];
            if (qrPath != null && qrPath is String && qrPath.isNotEmpty) {
              final qrUrl =
                  'https://backendscanevent-production.up.railway.app/qr_codes/$qrPath';
              await _downloadAndSaveQrImage(context, qrUrl);
            } else {
              debugPrint('❗ QR Code tidak tersedia');
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndSaveQrImage(
      BuildContext context, String imageUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Gagal mengunduh QR Code');
      }

      // Simpan sementara di direktori aplikasi
      final tempDir = await getTemporaryDirectory();
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Tampilkan dialog simpan sistem (langsung ke folder publik)
      final params = SaveFileDialogParams(sourceFilePath: tempFile.path);
      final savedPath = await FlutterFileDialog.saveFile(params: params);

      if (savedPath != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('✅ QR Code berhasil disimpan')),
        );
        debugPrint('✅ Disimpan di: $savedPath');
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('❌ Penyimpanan dibatalkan')),
        );
      }
    } catch (e) {
      debugPrint('❌ Gagal menyimpan QR Code: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('❌ Gagal menyimpan QR Code')),
      );
    }
  }
}
