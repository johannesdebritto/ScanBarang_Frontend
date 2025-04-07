import 'package:aplikasi_scan_barang/main.dart';
import 'package:aplikasi_scan_barang/pages/event/event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'detail_event_logic.dart';
import 'qr_list_component.dart';

class DetailEventScreen extends StatefulWidget {
  final String idEvent;
  final bool isSelesai;
  final bool fromHistory;

  const DetailEventScreen({
    Key? key,
    required this.idEvent,
    this.isSelesai = false,
    this.fromHistory = false,
  }) : super(key: key);

  @override
  State<DetailEventScreen> createState() => _DetailEventScreenState();
}

class _DetailEventScreenState extends State<DetailEventScreen> {
  Map<String, dynamic>? event;
  List<dynamic> qrCodes = [];
  bool isLoading = true, isButtonEnabled = false;
  late DetailEventLogic logic;

  @override
  void initState() {
    super.initState();
    logic = DetailEventLogic(idEvent: widget.idEvent);
    _loadData();
  }

  Future<void> _loadData() async {
    final eventDetail = await logic.fetchEventDetail();
    final qrCodeList = await logic.fetchQRCodeList();
    setState(() {
      event = eventDetail;
      qrCodes = qrCodeList;
      isLoading = false;
      isButtonEnabled = qrCodeList.every((qr) => qr['id_status'] == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 60), // ruang tombol
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleAndEditButton(),
                              // Status
                              Row(
                                children: [
                                  Icon(LucideIcons.info,
                                      color: Colors.lightBlue),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (event?['id_status'] == 2)
                                          ? Colors.orangeAccent
                                          : (event?['id_status'] == 1)
                                              ? Colors.green
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event?['status']?.toUpperCase() ??
                                          'UNKNOWN',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(thickness: 1, color: Colors.grey[300]),
                              // Tanggal dan Lokasi
                              _buildInfoRow(
                                  LucideIcons.calendar,
                                  "Tanggal: ${event?['tanggal'] != null ? logic.formatTanggal(event!['tanggal']) : 'Tidak diketahui'}",
                                  Colors.black,
                                  FontWeight.w700),
                              _buildInfoRow(
                                  LucideIcons.mapPin,
                                  "Lokasi: ${event?['kota'] ?? 'Tidak diketahui'}, ${event?['kabupaten'] ?? 'Tidak diketahui'}",
                                  Colors.black,
                                  FontWeight.w700),
                              const SizedBox(height: 16),
                              QRListComponent(
                                qrCodes: qrCodes,
                                logic: logic,
                                isSelesai: widget.isSelesai,
                                fromHistory: widget.fromHistory,
                                onAddBarcode: () {},
                                onDelete: (qrCode) =>
                                    logic.deleteQRCode(qrCode),
                              ),

                              const SizedBox(height: 80), // ruang tambahan
                            ],
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildFooter()),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: const BoxDecoration(
            color: Color(0xFF00509D),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        child: Center(
          child: Text(widget.isSelesai ? "Selesai" : "Detail Event",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white)),
        ),
      );

  Widget _buildTitleAndEditButton() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(event?['nama_event'] ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis)),
          if (!widget.isSelesai && !widget.fromHistory)
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventScreen(eventId: event?['id_event']),
                ),
              ).then((_) => _loadData()),
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

  Widget _buildFooter() => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!))),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildBackButton(),
            if (widget.isSelesai && !widget.fromHistory) _buildFinishButton(),
          ]),
        ),
      );

  Widget _buildBackButton() => ElevatedButton.icon(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(selectedIndex: widget.fromHistory ? 1 : 0),
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

  Widget _buildFinishButton() => ElevatedButton.icon(
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

  Widget _buildInfoRow(IconData icon, String text,
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
