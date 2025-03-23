import 'dart:convert';
import 'package:aplikasi_scan_barang/pages/barangpages/product_card_widget.dart';
import 'package:aplikasi_scan_barang/pages/barangpages/tambah_barang_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayBarangScreen extends StatefulWidget {
  const DisplayBarangScreen({super.key});

  @override
  State<DisplayBarangScreen> createState() => _DisplayBarangScreenState();
}

class _DisplayBarangScreenState extends State<DisplayBarangScreen> {
  List<String> _brands = ['Semua'];
  String? _selectedBrand;
  bool _isDropdownOpen = false;
  OverlayEntry? _dropdownOverlay;
  String _searchQuery = '';
  final GlobalKey _filterButtonKey = GlobalKey();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    final String apiUrl = "${dotenv.env['BASE_URL']}/api/barang/brands";

    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print("🔴 Gagal mendapatkan token Firebase.");
        throw Exception("Gagal mendapatkan token.");
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // ✅ Kirim token ke backend
        },
      );

      print("🟡 Response dari server: ${response.statusCode}");
      print("🟡 Body response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> brandList = json.decode(response.body);

        setState(() {
          _brands.clear();
          _brands.add("Semua"); // ✅ Tambahkan opsi "Semua" di awal
          _brands.addAll(brandList.map((brand) => brand['name'].toString()));

          _selectedBrand ??=
              "Semua"; // ✅ Pilih "Semua" sebagai default jika belum dipilih
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load brands");
      }
    } catch (e) {
      print("🔴 Error saat mengambil brands: $e");
      setState(() => _isLoading = false);
    }
  }

  void _toggleDropdown(BuildContext context, RenderBox buttonBox) {
    _isDropdownOpen ? _closeDropdown() : _openDropdown(context, buttonBox);
  }

  void _openDropdown(BuildContext context, RenderBox buttonBox) {
    final overlay = Overlay.of(context);
    final size = buttonBox.size;
    final position = buttonBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height + 8,
        left: position.dx - 100,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size.width + 100,
            decoration: BoxDecoration(
              color: const Color(0xFFced4da),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _brands
                  .map((brand) => ListTile(
                        title: Text(
                          brand,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        onTap: () {
                          setState(() => _selectedBrand = brand);
                          _closeDropdown();
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_dropdownOverlay!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    if (_isDropdownOpen) {
      setState(() => _isDropdownOpen = false);
    }
  }

  Widget _buildSearchBar() => Expanded(
        child: SizedBox(
          height: 48,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari',
              hintStyle: GoogleFonts.inter(fontSize: 14),
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      );

  Widget _buildFilterButton(BuildContext context) => SizedBox(
        key: _filterButtonKey,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4cc9f0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: () {
            final renderBox = _filterButtonKey.currentContext
                ?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              _toggleDropdown(context, renderBox);
            }
          },
          child: Row(
            children: [
              const Icon(Icons.filter_alt, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _selectedBrand ?? 'Filter',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: 'Data Barang',
          icon: Icons.inventory,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(width: 8.0),
                        Builder(
                          builder: (context) => _buildFilterButton(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ProductCardScreen(
                        searchQuery: _searchQuery,
                        selectedBrand:
                            _selectedBrand == "Semua" ? null : _selectedBrand,
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
                builder: (context) => TambahBarangScreen(
                    itemData:
                        null), // ✅ Tambahkan itemData null saat menambah barang baru
              ),
            ),
            backgroundColor: const Color(0xFF3a0ca3),
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            heroTag: 'uniqueHeroTag',
            child: const Icon(Icons.add, color: Colors.white, size: 40),
          ),
        ),
      );
}
