import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'detail_event_logic.dart';
import 'dart:convert';

// ... import tetap sama

class QRItem extends StatelessWidget {
  final dynamic qrData;
  final DetailEventLogic logic;
  final Function(String) onDelete;

  const QRItem({
    Key? key,
    required this.qrData,
    required this.logic,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic parsedData;
    try {
      parsedData = qrData['qr_code'] is String
          ? jsonDecode(qrData['qr_code'])
          : qrData['qr_code'];
    } catch (e) {
      parsedData = {};
      debugPrint("❌ Gagal decode qr_code: $e");
    }

    String statusText = qrData['id_status'] == 1 ? "Selesai" : "Dipakai";
    Color statusColor = qrData['id_status'] == 1 ? Colors.green : Colors.orange;

    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    Map<String, dynamic> normalized = {};
    parsedData.forEach((key, value) {
      normalized[key.toString().toLowerCase().replaceAll(' ', '_')] = value;
    });

    String imageUrl = normalized['imageurl'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl/images/$imageUrl';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    imageUrl.isNotEmpty
                        ? Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black26, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 80),
                              ),
                            ),
                          )
                        : const Icon(Icons.broken_image, size: 140),
                    const SizedBox(height: 15),
                    // Mulai Scan
                    _buildScanTextSection(
                      title: "Mulai Scan",
                      date: qrData['scan_date'] != null
                          ? logic.formatTanggal(qrData['scan_date'])
                          : '-',
                      time: qrData['scan_time'] != null
                          ? "${qrData['scan_time'].toString().substring(0, 5)} WIB"
                          : '-',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmojiRow("📦 Nama", normalized['name']),
                      _buildEmojiRow("🔢 Quantity", normalized['quantity']),
                      _buildEmojiRow("🆔 Code", normalized['code']),
                      _buildEmojiRow("🏷️ Brand", normalized['brand']),

                      const SizedBox(height: 4),

                      // Status biasa
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Status: $statusText",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),

                      // Selesai Scan
                      _buildScanTextSection(
                        title: "Selesai Scan",
                        date: qrData['tanggal_selesai'] != null
                            ? logic.formatTanggal(qrData['tanggal_selesai'])
                            : '-',
                        time: qrData['waktu_selesai'] != null
                            ? "${qrData['waktu_selesai'].toString().substring(0, 5)} WIB"
                            : '-',
                        color: Colors.green,
                      ),

                      const SizedBox(height: 12),

                      // Tombol Delete kanan bawah
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          onPressed: () => onDelete(qrData['qr_code']),
                          icon: const Icon(Icons.delete, size: 20),
                          label: const Text("Hapus"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Colors.black12), // penutup item
        ],
      ),
    );
  }

  Widget _buildEmojiRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: ${value ?? '-'}",
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildScanTextSection({
    required String title,
    required String date,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          _buildIconRow(Icons.calendar_today, date),
          _buildIconRow(Icons.access_time, time),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
