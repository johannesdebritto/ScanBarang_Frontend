import 'package:aplikasi_scan_barang/pages/barangpages/product_button.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/product_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final String name, brand, quantity, code, imageUrl, qrCodeUrl;
  final VoidCallback onDelete;
  final Map<String, dynamic> itemData;
  final Color borderColor;

  const ProductCard({
    super.key,
    required this.itemData,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.code,
    required this.imageUrl,
    required this.onDelete,
    this.borderColor = Colors.black,
    required this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor.withOpacity(0.8), width: 1.5),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(imageUrl: imageUrl, qrCodeUrl: qrCodeUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    const SizedBox(height: 12),
                    _buildDetailSection(),
                    const SizedBox(height: 12),
                    ProductButtons(
                      onDelete: onDelete,
                      itemData: itemData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(
                text: "Nama Barang : ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(
                text: "Brand Barang : ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: brand,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDetailChip(Icons.inventory_2_outlined, 'Stok: $quantity'),
        _buildDetailChip(Icons.qr_code, 'Kode: $code'),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
