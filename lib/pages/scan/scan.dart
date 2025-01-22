import 'dart:developer';
import 'dart:io';
import 'package:icons_plus/icons_plus.dart';
import '/pages/berandapages/beranda.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(const MaterialApp(home: QRViewExample()));

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF0052AB).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Scan Barcode Disini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052AB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                bool isFlashOn = snapshot.data == true;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isFlashOn
                                          ? Iconsax.flash_1_outline
                                          : Iconsax.flash_slash_outline,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isFlashOn ? 'Flash On' : 'Flash Off'),
                                  ],
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052AB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  bool isBackCamera =
                                      describeEnum(snapshot.data!) == 'back';
                                  return Text(
                                    isBackCamera
                                        ? 'Kamera Belakang'
                                        : 'Kamera Depan',
                                  );
                                } else {
                                  return const Text('Putar Kamera');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052AB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () async {
                          await controller?.pauseCamera();
                          if (context.mounted) {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        },
                        child: const Text('Selesai Scan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Color(0xFF0052AB),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        _showResultDialog(result!);
      }
    });
  }

  void _showResultDialog(Barcode barcode) async {
    // Pause kamera saat dialog muncul
    await controller?.pauseCamera();

    // Tampilkan dialog modal
    showDialog(
      context: context,
      barrierDismissible: false, // Modal tidak bisa ditutup dengan klik di luar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hasil Scan QR Code'),
          content: Text(
            'Barcode Type: ${describeEnum(barcode.format)}\nData: ${barcode.code}',
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup modal dialog
                    controller?.resumeCamera(); // Langsung resume kamera
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                        color: Colors.red), // Warna merah untuk membedakan
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup modal dialog
                    controller?.resumeCamera(); // Langsung resume kamera
                  },
                  child: const Text('Lanjutkan'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
