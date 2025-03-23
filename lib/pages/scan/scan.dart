import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scanner_screen_logic.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  late ScannerScreenLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = ScannerScreenLogic(context);
  }

  void _onDetect(Barcode barcode) {
    if (_logic.isDialogOpen || barcode.rawValue == null) return;

    setState(() {
      _logic.isDialogOpen = true;
      _logic.scannedData = barcode.rawValue;
    });

    _logic.showResultDialog(_logic.scannedData!);
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
          _buildSaveButton(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("QR Scanner",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Text("Arahkan kamera ke kode QR",
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 20,
      left: MediaQuery.of(context).size.width * 0.25,
      right: MediaQuery.of(context).size.width * 0.25,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_logic.scannedData != null) {
            _logic.sendScanResult(_logic.scannedData!);
          }
        },
        icon: Icon(LucideIcons.save, size: 18, color: Colors.white),
        label: Text(
          "Simpan",
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
