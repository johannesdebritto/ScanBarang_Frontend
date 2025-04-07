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
  final bool fromHistory; // ✅ Tambahan

  const EventCard({
    super.key,
    required this.event,
    required this.onDelete,
    required this.onDetailPressed,
    required this.onEditPressed,
    this.disableDetailButton = false,
    this.fromHistory = false, // ✅ Default false
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String _formatDate(String date) =>
      DateFormat('d-M-yyyy').format(DateTime.parse(date));

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
            _buildEventDetails(),
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
              fromHistory: widget.fromHistory, // ✅ Dikirim ke tombol
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
              widget.event['nama_event'],
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildEventDetails() {
    int? idStatus = widget.event['id_status'];
    Color statusBgColor;

    if (idStatus == 2) {
      statusBgColor = Colors.orangeAccent;
    } else if (idStatus == 1) {
      statusBgColor = Colors.green;
    } else {
      statusBgColor = Colors.grey;
    }

    return Column(
      children: [
        _buildDetailRow(
          Icons.date_range,
          _formatDate(widget.event['tanggal']),
          iconColor: Colors.orangeAccent,
        ),
        _buildDetailRow(
          Icons.location_on,
          "${widget.event['kota']}, ${widget.event['kabupaten']}",
          iconColor: Colors.green,
        ),
        Row(
          children: [
            Icon(Icons.info, color: Colors.lightBlue),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.event['status'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text,
      {TextStyle? textStyle, Color iconColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 8),
          Text(text,
              style: textStyle ??
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
