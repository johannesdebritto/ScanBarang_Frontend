import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 80, vertical: 5), // Jarak kiri-kanan & atas-bawah kecil
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 0.1), // Mengurangi padding vertikal
      decoration: BoxDecoration(
        color: const Color(0xFF007BFF), // Warna background navbar
        borderRadius: BorderRadius.circular(60), // Lengkungkan semua sudut
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.1), // Bayangan untuk efek floating
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(60), // Pastikan konten mengikuti lengkungan
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          type: BottomNavigationBarType.fixed, // Tampilan item statis
          backgroundColor:
              Colors.transparent, // Menghilangkan background default
          elevation: 0, // Menghilangkan efek shadow bawaan
          selectedItemColor: Colors.white, // Warna item aktif
          unselectedItemColor: Colors.white, // Warna item tidak aktif
          showSelectedLabels: true, // Menampilkan label pada item yang dipilih
          showUnselectedLabels:
              false, // Menyembunyikan label pada item yang tidak dipilih
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Iconsax.home_2_outline,
                isSelected: widget.currentIndex == 0,
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Iconsax.box_outline,
                isSelected: widget.currentIndex == 1,
              ),
              label: 'Barang',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Iconsax.clock_outline,
                isSelected: widget.currentIndex == 2,
              ),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon({required IconData icon, required bool isSelected}) {
    return Container(
      padding: isSelected
          ? const EdgeInsets.all(5.0) // Memberikan padding kecil saat dipilih
          : EdgeInsets.zero, // Tidak ada padding saat tidak dipilih
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.2)
            : Colors
                .transparent, // Lingkaran dengan warna transparan saat tidak dipilih
        shape: BoxShape.circle, // Bentuk lingkaran
      ),
      child: Icon(
        icon,
        size: isSelected ? 24 : 30, // Memperbesar ikon tidak aktif
        color: Colors
            .white, // Warna ikon tetap putih meskipun latar belakang berubah
      ),
    );
  }
}
