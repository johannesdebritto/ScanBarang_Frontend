import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'beranda_button.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(String) onDelete;
  final Function(String, bool) onDetailPressed;
  final Function(String) onEditPressed;
  final bool disableDetailButton;
  final bool fromHistory;

  const EventCard({
    super.key,
    required this.event,
    required this.onDelete,
    required this.onDetailPressed,
    required this.onEditPressed,
    this.disableDetailButton = false,
    this.fromHistory = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      return DateFormat('d-M-yyyy').format(DateTime.parse(date));
    } catch (e) {
      return '-';
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    try {
      return DateFormat('HH:mm').format(DateTime.parse("2000-01-01 $time"));
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventHeader(),
            const SizedBox(height: 8),
            _buildLocation(),
            const SizedBox(height: 6),
            _buildStatus(),
            const SizedBox(height: 8),
            _buildDateTimeRow(),
            const Divider(),
            BerandaButton(
              onDetailPressed: () {
                if (!widget.disableDetailButton) {
                  widget.onDetailPressed(
                    widget.event['id_event'].toString(),
                    false,
                  );
                }
              },
              onSelesaiPressed: () => widget.onDetailPressed(
                widget.event['id_event'].toString(),
                true,
              ),
              onEditPressed: () =>
                  widget.onEditPressed(widget.event['id_event'].toString()),
              disableDetailButton: widget.disableDetailButton,
              fromHistory: widget.fromHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(LucideIcons.bookCopy, color: Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              "Nama Event: ${widget.event['nama_event']}",
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 28),
            onPressed: () =>
                widget.onDelete(widget.event['id_event'].toString()),
          ),
        )
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Lokasi: ${widget.event['kota']}, ${widget.event['kabupaten']}",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold, // Memperbesar ukuran teks
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    int? idStatus = widget.event['id_status'];
    Color statusBgColor;
    String statusText = widget.event['status']?.toString().toUpperCase() ?? '';
    Color statusColor = Colors.black; // Default text color
    IconData statusIcon;

    // Tentukan warna status, ikon dan background berdasarkan idStatus
    if (idStatus == 2) {
      statusBgColor = Colors.orangeAccent.withOpacity(0.2);
      statusColor = Colors.orangeAccent;
      statusIcon = LucideIcons.loader; // Ikon loader
    } else if (idStatus == 1) {
      statusBgColor = Colors.green.withOpacity(0.2);
      statusColor = Colors.green;
      statusIcon = LucideIcons.badgeCheck; // Ikon loader
    } else {
      statusBgColor = Colors.grey.withOpacity(0.2);
      statusColor = Colors.grey;
      statusIcon = Icons.error; // Ikon error untuk status belum dimulai
    }

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 18, // Ukuran ikon bisa disesuaikan
          ),
          const SizedBox(width: 8), // Jarak antara ikon dan teks
          Text(
            "Status Tugas: ",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                Icons.date_range,
                "Tanggal Mulai:\n${_formatDate(widget.event['tanggal'])}",
                iconColor: Colors.purple,
              ),
              _buildDetailRow(
                Icons.access_time,
                "Waktu Mulai:\n${_formatTime(widget.event['waktu_dibuat'])} WIB",
                iconColor: Colors.purple,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                Icons.event_available,
                "Tanggal Selesai:\n${_formatDate(widget.event['tanggal_selesai'])}",
                iconColor: Colors.indigo,
              ),
              _buildDetailRow(
                Icons.access_time_filled,
                "Waktu Selesai:\n${_formatTime(widget.event['waktu_selesai'])} WIB",
                iconColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text,
      {TextStyle? textStyle, Color iconColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: textStyle ??
                  GoogleFonts.inter(
                      fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
