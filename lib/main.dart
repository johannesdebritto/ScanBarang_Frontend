import 'package:aplikasi_scan_barang/pages/barangpages/display_barang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/otorisasipages/login.dart';
import 'pages/historypages/history_screen.dart';
import 'pages/berandapages/beranda.dart';
import 'widgets/bottom_navbar.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await dotenv.load(fileName: ".env").catchError((e) {
    print("❌ ERROR: Gagal memuat .env - $e");
  });

  final prefs = await SharedPreferences.getInstance();
  bool? isFontDownloaded = prefs.getBool('isFontDownloaded');

  GoogleFonts.config.allowRuntimeFetching =
      isFontDownloaded == true ? false : true;

  if (isFontDownloaded == null) {
    await prefs.setBool('isFontDownloaded', true);
  }

  // **Pastikan Flutter Binding berjalan dengan benar untuk plugin**
  MobileScannerController(); // Inisialisasi scanner lebih awal untuk menghindari error

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(useMaterial3: true, textTheme: GoogleFonts.latoTextTheme()),
      home: LoginScreen(), // Mulai dari LoginScreen
    );
  }
}

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({Key? key, this.selectedIndex = 0})
      : super(key: key); // ✅ Tambahkan parameter selectedIndex

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex; // ✅ Gunakan selectedIndex saat init
  }

  final List<Widget> _pages = [
    BerandaScreen(),
    DisplayBarangScreen(), // 🆕 Tambahkan di sini
    HistoryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
