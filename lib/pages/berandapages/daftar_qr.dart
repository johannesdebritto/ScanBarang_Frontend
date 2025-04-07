import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_event_logic.dart';

class DaftarQR extends StatefulWidget {
  final List<dynamic> qrCodes;
  final DetailEventLogic logic;
  final Function(String) onDelete;

  const DaftarQR({
    Key? key,
    required this.qrCodes,
    required this.logic,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DaftarQR> createState() => _DaftarQRState();
}

class _DaftarQRState extends State<DaftarQR> {
  bool _isLoading = false;

  void _deleteQRCode(String qrCode) async {
    setState(() {
      _isLoading = true;
    });

    showLoadingDialog();

    await Future.delayed(Duration(seconds: 2)); // Simulasi proses penghapusan
    widget.onDelete(qrCode);

    if (mounted) {
      Navigator.pop(context); // Tutup dialog loading
      setState(() {
        widget.qrCodes.removeWhere((qr) => qr['qr_code'] == qrCode);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("QR Code berhasil dihapus!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Menghapus QR Code...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.qrCodes.map((qr) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.qr_code, color: Colors.black54),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qr['qr_code'],
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Tanggal Scan: ${widget.logic.formatTanggal(qr['scan_date'])}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Waktu Scan: ${qr['scan_time'].substring(0, 5)} WIB",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Status: ${qr['id_status'] == 2 ? 'Dipakai' : 'Selesai'}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: qr['id_status'] == 2 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed:
                    _isLoading ? null : () => _deleteQRCode(qr['qr_code']),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
