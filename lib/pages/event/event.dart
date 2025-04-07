import 'package:aplikasi_scan_barang/pages/event/event_button.dart';
import 'package:aplikasi_scan_barang/pages/event/event_form_screen.dart';
import 'package:flutter/material.dart';
import 'event_form_logic.dart'; // Import EventFormLogic

class EventScreen extends StatefulWidget {
  final int? eventId; // ✅ Tambahkan eventId

  const EventScreen(
      {super.key, this.eventId}); // ✅ Pastikan eventId bisa diterima

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventFormLogic _eventFormLogic = EventFormLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0052AB),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16.0),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text('Kembali', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventFormScreen(
                eventFormLogic: _eventFormLogic,
                eventId: widget.eventId, // ✅ Kirim eventId ke form
              ),
              const SizedBox(height: 20),
              // ✅ Pastikan eventId dikirim ke tombol!
              EventButtonScreen(
                eventFormLogic: _eventFormLogic,
                eventId: widget
                    .eventId, // 🔥 Kirim eventId biar tombolnya sesuai mode
              ),
            ],
          ),
        ),
      ),
    );
  }
}
