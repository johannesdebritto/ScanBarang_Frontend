import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'detail_event_logic.dart';
import 'qr_list_component.dart';
import 'detail_event_components.dart';

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

  Widget _buildDetailRow(IconData icon, String text,
      {Color iconColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
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
                "Tanggal Mulai:\n${event?['tanggal'] != null ? logic.formatTanggal(event!['tanggal']) : '-'}",
                iconColor: Colors.purple,
              ),
              _buildDetailRow(
                Icons.access_time,
                "Waktu Mulai:\n${event?['waktu_dibuat'] != null ? logic.formatWaktu(event!['waktu_dibuat']) : '-'} WIB",
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
                "Tanggal Selesai:\n${event?['tanggal_selesai'] != null ? logic.formatTanggal(event!['tanggal_selesai']) : '-'}",
                iconColor: Colors.indigo,
              ),
              _buildDetailRow(
                Icons.access_time_filled,
                "Waktu Selesai:\n${event?['waktu_selesai'] != null ? logic.formatWaktu(event!['waktu_selesai']) : '-'} WIB",
                iconColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    int? idStatus = event?['id_status'];
    Color statusBgColor;
    String statusText = event?['status']?.toString().toUpperCase() ?? '';
    Color statusColor = Colors.black;
    IconData statusIcon;

    if (idStatus == 2) {
      statusBgColor = Colors.orangeAccent.withOpacity(0.2);
      statusColor = Colors.orangeAccent;
      statusIcon = LucideIcons.loader;
    } else if (idStatus == 1) {
      statusBgColor = Colors.green.withOpacity(0.2);
      statusColor = Colors.green;
      statusIcon = LucideIcons.badgeCheck;
    } else {
      statusBgColor = Colors.grey.withOpacity(0.2);
      statusColor = Colors.grey;
      statusIcon = Icons.error;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DetailEventComponents.buildHeader(widget.isSelesai),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DetailEventComponents.buildTitleAndEditButton(
                                context: context,
                                event: event,
                                isSelesai: widget.isSelesai,
                                fromHistory: widget.fromHistory,
                                loadData: _loadData,
                              ),
                              _buildStatus(),
                              Divider(thickness: 1, color: Colors.grey[300]),
                              // Lokasi di atas
                              DetailEventComponents.buildInfoRow(
                                LucideIcons.mapPin,
                                "Lokasi: ${event?['kota'] ?? 'Tidak diketahui'}, ${event?['kabupaten'] ?? 'Tidak diketahui'}",
                                Colors.black,
                                FontWeight.w700,
                              ),
                              const SizedBox(height: 8),
                              // Tanggal dan waktu diubah jadi row format
                              _buildDateTimeRow(),
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
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: DetailEventComponents.buildFooter(
                          context: context,
                          isSelesai: widget.isSelesai,
                          fromHistory: widget.fromHistory,
                          isButtonEnabled: isButtonEnabled,
                          logic: logic,
                          event: event,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
