// import 'dart:convert'; // Tambahkan ini untuk JSON encoder
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_screen_logic.dart';

class ScannerScreen extends StatefulWidget {
  final String idEvent;
  final bool isSelesai;

  const ScannerScreen({
    Key? key,
    required this.idEvent,
    required this.isSelesai,
  }) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  late ScannerScreenLogic _logic;
  bool isSelesaiMode = false;

  @override
  void initState() {
    super.initState();
    _logic = ScannerScreenLogic(context, widget.idEvent);
    isSelesaiMode = widget.isSelesai;
  }

  void _onDetect(Barcode barcode) {
    if (_logic.isDialogOpen || barcode.rawValue == null) return;

    String raw = barcode.rawValue!;

    setState(() {
      _logic.isDialogOpen = true;
      _logic.scannedData = raw;
    });

    if (isSelesaiMode) {
      _logic.completeQRCode(raw, widget.idEvent, context);
    } else {
      _logic.showResultDialog(raw, isSelesaiMode); // langsung pakai raw
    }
  }

  void toggleMode() {
    setState(() {
      isSelesaiMode = !isSelesaiMode;
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
            onDetect: (capture) => _onDetect(capture.barcodes.first),
          ),
          _instructionText(),
          _saveButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        isSelesaiMode ? "QR Scanner - Selesai" : "QR Scanner",
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blueGrey[900],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(LucideIcons.flashlight),
          onPressed: () => cameraController.toggleTorch(),
        ),
        IconButton(
          icon: Icon(LucideIcons.camera),
          onPressed: () => cameraController.switchCamera(),
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
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
            idEvent: widget.idEvent,
            isSelesai: widget.isSelesai,
          );
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
