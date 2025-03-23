import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Import Firebase Auth
import 'tambah_barang_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCardScreen extends StatefulWidget {
  final String searchQuery;
  final String? selectedBrand;

  const ProductCardScreen({
    super.key,
    required this.searchQuery,
    this.selectedBrand,
  });

  @override
  State<ProductCardScreen> createState() => _ProductCardScreenState();
}

class _ProductCardScreenState extends State<ProductCardScreen> {
  late Future<List<dynamic>> futureItems;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems();
  }

  Future<List<dynamic>> fetchItems() async {
    try {
      // 🔥 Ambil ID Token dari Firebase Auth
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print('🔴 Gagal mendapatkan token.');
        throw Exception('Gagal mendapatkan token.');
      }

      print('🟢 ID Token diperoleh: $token'); // ✅ Cek apakah token sudah ada

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/barang'),
        headers: {
          'Authorization': 'Bearer $token', // ✅ Kirim token ke backend
        },
      );

      print('🟡 Response dari server: ${response.statusCode}');
      print('🟡 Body response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            items = data;
          });
        }
        print('🟢 Data barang berhasil diambil: $data');
        return data;
      } else {
        print('🔴 Gagal mengambil data barang. Status: ${response.statusCode}');
        throw Exception(
            'Gagal mengambil data barang. Status: ${response.statusCode}');
      }
    } catch (error) {
      print('🔴 Terjadi kesalahan saat mengambil data barang: $error');
      throw Exception('Terjadi kesalahan saat mengambil data barang: $error');
    }
  }

  Future<void> refreshItems() async {
    setState(() {
      futureItems = fetchItems();
    });
  }

  Future<void> deleteItem(String itemId) async {
    try {
      // 🔥 Ambil ID Token dari Firebase Auth
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception('Gagal mendapatkan token Firebase.');

      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/barang/$itemId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ✅ Kirim token ke backend
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Barang berhasil dihapus!");
        await refreshItems(); // 🔄 Perbarui daftar barang setelah dihapus
      } else if (response.statusCode == 404) {
        throw Exception("❌ Barang tidak ditemukan atau tidak memiliki akses.");
      } else {
        throw Exception(
            "❌ Gagal menghapus barang. Status: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (error) {
      print("❌ Error saat menghapus barang: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshItems,
      child: FutureBuilder<List<dynamic>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada barang tersedia'));
          }

          final filteredItems = items.where((item) {
            final matchesSearch = widget.searchQuery.isEmpty ||
                item['name']
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase());

            final matchesBrand = widget.selectedBrand == null ||
                widget.selectedBrand == "Semua" ||
                item['brand'] == widget.selectedBrand;

            return matchesSearch && matchesBrand;
          }).toList();

          return filteredItems.isEmpty
              ? const Center(child: Text('Barang tidak ditemukan'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ProductCard(
                      itemData: item,
                      name: item['name'],
                      brand: item['brand'],
                      quantity: item['quantity'].toString(),
                      code: item['code'],
                      imageUrl: item['image_url'] != null
                          ? '${dotenv.env['BASE_URL']}/images/${item['image_url']}'
                          : '',
                      onDelete: () {
                        if (item['id'] != null) {
                          deleteItem(item['id'].toString());
                        } else {
                          print("❌ Error: ID barang null, tidak bisa dihapus.");
                        }
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String brand;
  final String quantity;
  final String code;
  final String imageUrl;
  final VoidCallback onDelete;
  final Map<String, dynamic> itemData;

  const ProductCard({
    super.key,
    required this.itemData,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.code,
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3A0CA3), // Warna biru ungu
                    ),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.black),
                      children: [
                        const TextSpan(text: '• '), // Titik Bullet
                        TextSpan(
                          text: 'Brand : ',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600), // Bold dikit
                        ),
                        TextSpan(text: brand), // Nama brand tetap normal
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Stok & Kode dalam box dengan sudut tumpul
                  Row(
                    children: [
                      _buildInfoBox('Stok: $quantity'),
                      const SizedBox(width: 10),
                      _buildInfoBox('Kode: $code'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tombol Edit & Hapus di bawah Stok dan Kode
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        text: "Edit",
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahBarangScreen(
                                itemData: itemData,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.delete_forever,
                        text: "Hapus",
                        color: Colors.redAccent,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey, // Warna border
          width: 1.5, // Ketebalan border
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Widget untuk tombol Edit & Hapus
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
