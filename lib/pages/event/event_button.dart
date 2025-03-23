import 'package:aplikasi_scan_barang/pages/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'event_form_logic.dart'; // Import logic form

class EventButtonScreen extends StatefulWidget {
  final EventFormLogic eventFormLogic;

  const EventButtonScreen({Key? key, required this.eventFormLogic})
      : super(key: key);

  @override
  State<EventButtonScreen> createState() => _EventButtonScreenState();
}

class _EventButtonScreenState extends State<EventButtonScreen> {
  bool _isEventSaved = false; // State untuk mengontrol tombol scan

  void _saveEvent() async {
    bool success = await widget.eventFormLogic.simpanEvent(context);
    if (success) {
      setState(() {
        _isEventSaved = true; // Aktifkan tombol scan jika sukses
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tombol Simpan Event
        ElevatedButton.icon(
          onPressed: _saveEvent,
          icon: const Icon(LucideIcons.save, color: Colors.white),
          label: Text(
            "Simpan Event",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
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
        const SizedBox(width: 16), // Jarak antar tombol

        // Tombol Scan (Awalnya disabled)
        ElevatedButton.icon(
          onPressed: _isEventSaved
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScannerScreen()),
                  );
                }
              : null, // Disabled jika event belum tersimpan
          icon: const Icon(LucideIcons.scanLine, color: Colors.white),
          label: Text(
            "Scan",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
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
      ],
    );
  }
}
