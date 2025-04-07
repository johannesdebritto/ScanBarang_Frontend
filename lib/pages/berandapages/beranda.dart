import 'package:aplikasi_scan_barang/pages/berandapages/beranda_card.dart';
import 'package:aplikasi_scan_barang/pages/berandapages/detail_event.dart';
import 'package:aplikasi_scan_barang/pages/event/event.dart';
import 'package:aplikasi_scan_barang/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beranda_logic.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _logic = BerandaLogic();
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Pengguna';
    });
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      _events = await _logic.fetchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Menghapus QR Barang...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteEvent(String id) async {
    final confirmed = await _showDeleteDialog();

    if (confirmed == true) {
      _showLoadingDialog();
      final result = await _logic.deleteEvent(id, context);
      Navigator.pop(context);

      if (result) {
        _loadEvents();
      }
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin menghapus event ini?',
            style: TextStyle(fontSize: 16)),
        actions: [
          _buildDialogButton('Batal', Colors.red, Colors.white, false),
          _buildDialogButton('Hapus', Colors.green, Colors.white, true),
        ],
      ),
    );
  }

  TextButton _buildDialogButton(
      String label, Color bgColor, Color textColor, bool result) {
    return TextButton(
      onPressed: () => Navigator.pop(context, result),
      style: TextButton.styleFrom(backgroundColor: bgColor, primary: textColor),
      child: Text(label),
    );
  }

  void _navigateToDetail(String idEvent, bool isSelesai) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailEventScreen(idEvent: idEvent, isSelesai: isSelesai),
      ),
    );
  }

  void _navigateToEdit(String id) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventScreen(eventId: int.tryParse(id))))
        .then((_) => _loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Dashboard', icon: Icons.dashboard),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selamat Datang, ${username ?? '...'}',
            style:
                GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            border: Border.all(color: const Color(0xFF004e89), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            const Icon(Icons.event, color: Color(0xFF00509D), size: 28),
            const SizedBox(width: 8),
            Text('EVENT BERLANGSUNG',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00509D))),
          ]),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // FILTER HANYA EVENT YANG BERLANGSUNG (id_status == 2)
    final filteredEvents = _events.where((e) => e['id_status'] == 2).toList();

    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text('BELUM ADA EVENT BERLANGSUNG',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) => EventCard(
          event: filteredEvents[index],
          onDelete: _handleDeleteEvent,
          onDetailPressed: _navigateToDetail,
          onEditPressed: _navigateToEdit,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 90,
      height: 90,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => EventScreen()))
            .then((_) => _loadEvents()),
        backgroundColor: const Color(0xFF00509D),
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }
}
