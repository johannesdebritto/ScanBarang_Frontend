import 'package:aplikasi_scan_barang/pages/barangpages/display_logic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/product_card_widget.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/tambah_barang_screen.dart';

import '/widgets/custom_app_bar.dart';

class DisplayBarangScreen extends StatefulWidget {
  DisplayBarangScreen({super.key});

  @override
  State<DisplayBarangScreen> createState() => _DisplayBarangScreenState();
}

class _DisplayBarangScreenState extends State<DisplayBarangScreen> {
  final DisplayBarangLogic _logic = DisplayBarangLogic();

  @override
  void initState() {
    super.initState();
    _logic.fetchData().then((_) {
      if (mounted) setState(() {});
    }).catchError((error) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildSearchBar() => Expanded(
        child: SizedBox(
          height: 48,
          child: TextField(
            onChanged: (value) => setState(() => _logic.searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari',
              hintStyle: GoogleFonts.inter(fontSize: 14),
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Data Barang',
          icon: Icons.inventory,
        ),
        body: _logic.isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildSearchBar(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ProductCardScreen(
                        searchQuery: _logic.searchQuery,
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TambahBarangScreen(itemData: null),
              ),
            ),
            backgroundColor: Color(0xFF3a0ca3),
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            heroTag: 'uniqueHeroTag',
            child: Icon(Icons.add, color: Colors.white, size: 40),
          ),
        ),
      );
}
