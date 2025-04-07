import 'package:aplikasi_scan_barang/pages/berandapages/detail_event.dart';
import 'package:aplikasi_scan_barang/pages/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'event_form_logic.dart'; // Import logic form

class EventButtonScreen extends StatefulWidget {
  final EventFormLogic eventFormLogic;
  final int? eventId; // Ubah ke int agar sesuai dengan logic

  const EventButtonScreen({
    Key? key,
    required this.eventFormLogic,
    this.eventId,
  }) : super(key: key);

  @override
  State<EventButtonScreen> createState() => _EventButtonScreenState();
}

class _EventButtonScreenState extends State<EventButtonScreen> {
  bool _isEventSaved = false;

  void _saveEvent() async {
    bool success = await widget.eventFormLogic
        .simpanAtauEditEvent(context, eventId: widget.eventId);

    if (success && mounted) {
      if (widget.eventId == null) {
        // ✅ Mode Tambah: Tetap di halaman ini & aktifkan tombol Scan
        setState(() {
          _isEventSaved = true;
        });
      } else {
        // ✅ Mode Edit: Navigasi ke DetailEventScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DetailEventScreen(
              idEvent: widget.eventId?.toString() ?? "0", // Pastikan ID valid
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.eventId == null) ...[
          // ✅ Mode Tambah (Simpan Data + Scan)
          ElevatedButton.icon(
            onPressed: _saveEvent,
            icon: const Icon(LucideIcons.save, color: Colors.white),
            label: Text(
              "Simpan Data",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isEventSaved
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScannerScreen(
                          idEvent: '',
                          isSelesai: false, // Tambahkan ini
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(LucideIcons.scanLine, color: Colors.white),
            label: Text(
              "Scan",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEventSaved ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ] else ...[
          // ✅ Mode Edit (Update Event)
          ElevatedButton.icon(
            onPressed: _saveEvent,
            icon: const Icon(LucideIcons.save, color: Colors.white),
            label: Text(
              "Update Event",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
