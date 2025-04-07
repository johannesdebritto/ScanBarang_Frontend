import 'package:aplikasi_scan_barang/pages/berandapages/beranda_logic.dart';
import 'package:aplikasi_scan_barang/pages/historypages/search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_scan_barang/widgets/custom_app_bar.dart';
import 'package:aplikasi_scan_barang/pages/berandapages/beranda_card.dart';
import 'package:aplikasi_scan_barang/pages/berandapages/detail_event.dart';
import 'package:aplikasi_scan_barang/pages/event/event.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final BerandaLogic _logic = BerandaLogic();
  List<dynamic> _events = [];
  bool _isLoading = true;

  final List<String> _filters = [
    'Semua',
    'Hari Ini',
    '7 Hari Terakhir',
    'Terbaru ke Terlama',
    'Terlama ke Terbaru',
  ];
  String? _selectedFilter;
  String _searchQuery = ''; // 🔍 Simpan keyword pencarian

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final data = await _logic.fetchEvents();
      final filtered = data.where((e) => e['id_status'] == 1).toList();
      setState(() {
        _events = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat: $e")));
    }
  }

  Future<void> _handleDeleteEvent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _logic.deleteEvent(id, context);
        if (success) _loadEvents();
      } catch (_) {}
    }
  }

  void _navigateToDetail(String idEvent, bool isSelesai) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailEventScreen(
          idEvent: idEvent,
          isSelesai: isSelesai,
          fromHistory: true,
        ),
      ),
    );
  }

  void _navigateToEdit(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventScreen(eventId: int.tryParse(id)),
      ),
    ).then((_) => _loadEvents());
  }

  void _onFilterSelected(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // bisa tambah logika filter nanti
  }

  // 🔍 Auto Filter berdasarkan input search
  List<dynamic> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events.where((event) {
      final name = (event['nama_event'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Riwayat', icon: Icons.history),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SearchFilterBar(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onFilterSelected: _onFilterSelected,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery =
                          value.toLowerCase(); // Simpan keyword search
                    });
                  },
                ),
                Expanded(
                  child: _filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.history_toggle_off,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("Tidak ada riwayat",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEvents,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredEvents.length,
                            itemBuilder: (context, index) {
                              return EventCard(
                                event: _filteredEvents[index],
                                onDelete: _handleDeleteEvent,
                                onDetailPressed: _navigateToDetail,
                                onEditPressed: _navigateToEdit,
                                disableDetailButton: true,
                                fromHistory: true, // ⬅️ Tambahkan ini
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
