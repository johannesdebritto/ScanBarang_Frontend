import 'package:aplikasi_scan_barang/pages/event/event.dart';
import 'package:flutter/material.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Tinggi AppBar
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16), // Melengkung di bagian bawah
            top: Radius.circular(16), // Melengkung di bagian atas
          ),
          child: AppBar(
            backgroundColor: Color(0xFF3a0ca3), // Warna biru gelap
            elevation: 2,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.dashboard,
                    color: Colors.white, size: 28), // Ikon dashboard
                SizedBox(width: 8),
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            centerTitle: false,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10), // Spasi dari AppBar
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD), // Biru muda lembut
                border: Border.all(
                  color: Color(0xFF004e89), // Border biru gelap
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Color(0xFF00509D), // Ikon biru gelap
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'EVENT BERLANGSUNG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00509D),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: Text(
                'BELUM ADA EVENT BERLANGSUNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF757575), // Abu-abu gelap
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 80, // Lebar FAB
        height: 80, // Tinggi FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventScreen()),
            );
          },
          backgroundColor: Color(0xFF3a0ca3), // Warna biru terang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Sudut melengkung
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 40, // Ukuran ikon
          ),
        ),
      ),
    );
  }
}
