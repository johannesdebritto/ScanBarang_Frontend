import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'product_card.dart';

class ProductCardScreen extends StatefulWidget {
  final String searchQuery;
  final String? selectedBrand;

  ProductCardScreen({
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
  bool isDeleting = false; // Menambahkan flag untuk indikator delete

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems();
  }

  Future<List<dynamic>> fetchItems() async {
    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print('🔴 Gagal mendapatkan token.');
        throw Exception('Gagal mendapatkan token.');
      }

      print('🟢 ID Token diperoleh: $token');

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/barang'),
        headers: {
          'Authorization': 'Bearer $token',
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
    setState(() {
      isDeleting = true; // Menandakan bahwa sedang menghapus barang
    });

    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception('Gagal mendapatkan token Firebase.');

      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/barang/$itemId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Barang berhasil dihapus!");
        await refreshItems(); // Refresh daftar barang setelah penghapusan
        setState(() {
          isDeleting = false; // Reset deleting flag
        });
      } else if (response.statusCode == 404) {
        throw Exception("❌ Barang tidak ditemukan atau tidak memiliki akses.");
      } else {
        throw Exception(
            "❌ Gagal menghapus barang. Status: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (error) {
      setState(() {
        isDeleting = false; // Reset deleting flag jika ada error
      });
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada barang tersedia'));
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
              ? Center(child: Text('Barang tidak ditemukan'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
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
                      qrCodeUrl: item['qr_code_url'] != null
                          ? '${dotenv.env['BASE_URL']}/qr_codes/${item['qr_code_url']}'
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
