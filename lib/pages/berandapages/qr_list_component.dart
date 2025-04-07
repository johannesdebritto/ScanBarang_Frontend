import 'package:aplikasi_scan_barang/pages/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_event_logic.dart';

class QRListComponent extends StatefulWidget {
  final List<dynamic> qrCodes;
  final DetailEventLogic logic;
  final VoidCallback onAddBarcode;
  final Function(String) onDelete;
  final bool isSelesai;
  final bool fromHistory; // ✅ tambahan

  const QRListComponent({
    Key? key,
    required this.qrCodes,
    required this.logic,
    required this.onAddBarcode,
    required this.onDelete,
    required this.isSelesai,
    required this.fromHistory, // ✅ tambahan
  }) : super(key: key);

  @override
  State<QRListComponent> createState() => _QRListComponentState();
}

class _QRListComponentState extends State<QRListComponent> {
  bool _isLoading = false;
  List<dynamic> _qrCodes = [];

  @override
  void initState() {
    super.initState();
    fetchAndRefreshQRCodeList();
  }

  @override
  void didUpdateWidget(covariant QRListComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelesai != widget.isSelesai ||
        oldWidget.logic.idEvent != widget.logic.idEvent) {
      fetchAndRefreshQRCodeList();
    }
  }

  Future<void> fetchAndRefreshQRCodeList() async {
    setState(() => _isLoading = true);
    List<dynamic> data = await widget.logic.fetchQRCodeList();
    if (mounted) {
      setState(() {
        _qrCodes = data;
        _isLoading = false;
      });
    }
  }

  void _deleteQRCode(String qrCode) async {
    setState(() => _isLoading = true);
    _showLoadingDialog();

    bool success = await widget.logic.deleteQRCode(qrCode);

    if (mounted) {
      Navigator.pop(context);
      setState(() => _isLoading = false);
      if (success) {
        widget.onDelete(qrCode);
        fetchAndRefreshQRCodeList();
      } else {
        _showSnackbar("Gagal menghapus QR Code.");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text("Menghapus QR Barang...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showScanButton =
        (widget.isSelesai && !widget.fromHistory) || !widget.isSelesai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 0.5, color: Colors.grey[300]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Daftar QR Code",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (showScanButton)
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerScreen(
                        idEvent: widget.logic.idEvent.toString(),
                        isSelesai: widget.isSelesai,
                      ),
                    ),
                  );
                  if (result == true) {
                    fetchAndRefreshQRCodeList();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.isSelesai ? Colors.green : Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: Icon(widget.isSelesai ? Icons.qr_code : Icons.add,
                    color: Colors.white),
                label: Text(
                  widget.isSelesai ? "Scan Selesai" : "Tambah Barcode",
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        _isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              "Memuat daftar barang...",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _qrCodes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Belum ada QR Code yang discan",
                        style:
                            GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: _qrCodes.map((qr) => _qrItem(qr)).toList(),
                  ),
      ],
    );
  }

  Widget _qrItem(dynamic qr) {
    String status = qr['id_status'] == 1 ? "Selesai" : "Dipakai";
    Color statusColor =
        qr['id_status'] == 1 ? Colors.green : Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.qr_code, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qr['qr_code'],
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "Tanggal Scan: ${widget.logic.formatTanggal(qr['scan_date'])}",
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                Text(
                  "Waktu Scan: ${qr['scan_time'].substring(0, 5)} WIB",
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                Text(
                  "Status: $status",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteQRCode(qr['qr_code']),
          ),
        ],
      ),
    );
  }
}
