import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_screen_logic.dart';

class ScannerScreen extends StatefulWidget {
  final String idEvent; // Tambahkan parameter idEvent
  final bool isSelesai; // Tambahkan ini

  const ScannerScreen(
      {Key? key, required this.idEvent, required this.isSelesai})
      : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  late ScannerScreenLogic _logic;
  bool isSelesaiMode =
      false; // Menambahkan boolean untuk mengontrol mode selesai atau tidak

  @override
  void initState() {
    super.initState();
    _logic = ScannerScreenLogic(context, widget.idEvent); // Teruskan idEvent
    isSelesaiMode =
        widget.isSelesai; // Pastikan mode sesuai dengan yang dikirim
  }

  void _onDetect(Barcode barcode) {
    if (_logic.isDialogOpen || barcode.rawValue == null) return;

    setState(() {
      _logic.isDialogOpen = true;
      _logic.scannedData = barcode.rawValue;
    });

    // Tentukan apakah result ini 'Selesai' atau biasa berdasarkan kondisi
    if (isSelesaiMode) {
      // Panggil completeQRCode dengan idEvent tetap String
      _logic.completeQRCode(barcode.rawValue!, widget.idEvent, context);
    } else {
      _logic.showResultDialog(barcode.rawValue!, isSelesaiMode);
    }
  }

  void toggleMode() {
    setState(() {
      isSelesaiMode = !isSelesaiMode; // Toggle mode selesai atau tidak
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          MobileScanner(
              controller: cameraController,
              onDetect: (capture) => _onDetect(capture.barcodes.first)),
          _instructionText(),
          _saveButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        isSelesaiMode
            ? "QR Scanner - Selesai"
            : "QR Scanner", // Ganti judul berdasarkan mode
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blueGrey[900],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
            icon: Icon(LucideIcons.flashlight),
            onPressed: () => cameraController.toggleTorch()),
        IconButton(
            icon: Icon(LucideIcons.camera),
            onPressed: () => cameraController.switchCamera()),
      ],
    );
  }

  Widget _instructionText() {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Text(
            isSelesaiMode
                ? "Arahkan kamera ke kode QR untuk menyelesaikan."
                : "Arahkan kamera ke kode QR untuk memindai.",
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return Positioned(
      bottom: 20,
      left: MediaQuery.of(context).size.width * 0.25,
      right: MediaQuery.of(context).size.width * 0.25,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          print("📌 Menyimpan data dengan idEvent: ${widget.idEvent}");
          _logic.closeScannerScreen(
              idEvent: widget.idEvent, isSelesai: widget.isSelesai);
        },
        icon: Icon(LucideIcons.save),
        label: Text(
          "Simpan Data",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
