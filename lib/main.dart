import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/barangpages/display_barang.dart';
import 'pages/historypages/history.dart';
import 'pages/berandapages/beranda.dart';
import 'widgets/bottom_navbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(useMaterial3: true, textTheme: GoogleFonts.latoTextTheme()),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BerandaScreen(),
    DisplayBarangScreen(),
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
