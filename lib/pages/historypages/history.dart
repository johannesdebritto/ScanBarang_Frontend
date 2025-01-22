import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _brands = [
    'Hari Ini',
    '7 Hari Terakhir',
    'Terbaru ke Terlama',
    'Terlama ke Terbaru',
  ];

  String? _selectedBrand;
  bool _isDropdownOpen =
      false; // Untuk memantau apakah dropdown terbuka atau tidak
  OverlayEntry? _dropdownOverlay;

  void _toggleDropdown(BuildContext context, RenderBox buttonBox) {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown(context, buttonBox);
    }
  }

  void _openDropdown(BuildContext context, RenderBox buttonBox) {
    final overlay = Overlay.of(context);
    final size = buttonBox.size;
    final position = buttonBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy +
            size.height +
            8, // Tambahkan jarak antara dropdown dan tombol
        left: position.dx - 100, // Geser ke kiri untuk memperluas dropdown
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size.width + 100, // Perluas lebar dropdown ke kiri
            decoration: BoxDecoration(
              color: const Color(0xFFced4da), // Warna background dropdown
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _brands.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_brands[index]),
                  onTap: () {
                    setState(() {
                      _selectedBrand = _brands[index];
                    });
                    _closeDropdown();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_dropdownOverlay!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
            top: Radius.circular(16),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF3a0ca3),
            elevation: 2,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.history_edu, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Riwayat',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            centerTitle: false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0), // Menambahkan padding vertikal
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  height: 48,
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4cc9f0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          final buttonBox =
                              context.findRenderObject() as RenderBox;
                          _toggleDropdown(context, buttonBox);
                        },
                        child:
                            const Icon(Icons.filter_alt, color: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
            Spacer(),
            // Menampilkan pesan "Barang masih kosong"
            Center(
              child: Text(
                'Riwayat masih kosong',
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
    );
  }
}
