import 'package:flutter/material.dart';
import '/widgets/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = [
    'Hari Ini',
    '7 Hari Terakhir',
    'Terbaru ke Terlama',
    'Terlama ke Terbaru',
  ];

  String? _selectedFilter;
  bool _isDropdownOpen = false;
  OverlayEntry? _dropdownOverlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Riwayat',
        icon: Icons.history_edu,
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
                        hintText: 'Cari Riwayat',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
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
                        onPressed: () {},
                        child:
                            const Icon(Icons.filter_alt, color: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                'Riwayat masih kosong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
