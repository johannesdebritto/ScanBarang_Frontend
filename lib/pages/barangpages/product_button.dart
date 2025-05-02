import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_scan_barang/widgets/delete_modal.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/tambah_barang_screen.dart';

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
        // Row untuk tombol Edit dan Hapus
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
                    context: context, onDelete: onDelete);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tombol Download QR diletakkan terpisah
        _buildActionButton(
          context,
          icon: Icons.qr_code_2_outlined,
          label: 'Download QR',
          color: Colors.blue.shade900,
          onTap: () {
            // Kosong dulu
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
}
