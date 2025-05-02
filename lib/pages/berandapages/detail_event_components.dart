import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:aplikasi_scan_barang/main.dart';
import 'package:aplikasi_scan_barang/pages/event/event.dart';
import 'detail_event_logic.dart';

class DetailEventComponents {
  static Widget buildHeader(bool isSelesai) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: const BoxDecoration(
            color: Color(0xFF00509D),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        child: Center(
          child: Text(isSelesai ? "Selesai" : "Detail Event",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white)),
        ),
      );

  static Widget buildTitleAndEditButton({
    required BuildContext context,
    required Map<String, dynamic>? event,
    required bool isSelesai,
    required bool fromHistory,
    required Function loadData,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text("Nama Event : ${event?['nama_event'] ?? ''}",
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis)),
          if (!isSelesai && !fromHistory)
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventScreen(eventId: event?['id_event']),
                ),
              ).then((_) => loadData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.pencilLine, color: Colors.white),
              label: Text("Edit",
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      );

  static Widget buildFooter({
    required BuildContext context,
    required bool isSelesai,
    required bool fromHistory,
    required bool isButtonEnabled,
    required DetailEventLogic logic,
    required Map<String, dynamic>? event,
  }) =>
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!))),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildBackButton(context, fromHistory),
            if (isSelesai && !fromHistory)
              _buildFinishButton(context, isButtonEnabled, logic),
          ]),
        ),
      );

  static Widget _buildBackButton(BuildContext context, bool fromHistory) =>
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(selectedIndex: fromHistory ? 2 : 0),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blue[900]!, width: 2))),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: Text("Kembali",
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );

  static Widget _buildFinishButton(
          BuildContext context, bool isButtonEnabled, DetailEventLogic logic) =>
      ElevatedButton.icon(
        onPressed: isButtonEnabled
            ? () async {
                final success = await logic.completeEvent();
                if (success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("✅ Event berhasil diselesaikan")));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(selectedIndex: 0)),
                      (route) => false,
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Gagal menyelesaikan event")));
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isButtonEnabled ? Colors.green[900]! : Colors.grey,
                width: 2),
          ),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text("Simpan Data",
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );

  static Widget buildInfoRow(IconData icon, String text,
          [Color? color, FontWeight fontWeight = FontWeight.w500]) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black54),
            const SizedBox(width: 8),
            Text(text,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: fontWeight, color: color)),
          ],
        ),
      );
}
