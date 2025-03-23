import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormBarangScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const FormBarangScreen({super.key, this.initialData});

  @override
  FormBarangScreenState createState() => FormBarangScreenState();
}

class FormBarangScreenState extends State<FormBarangScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedBrand;
  List<String> _brands = [];
  bool _isLoading = true;

  @override
  @override
  void initState() {
    super.initState();
    _fetchBrands().then((_) {
      if (widget.initialData != null) {
        setInitialData(widget.initialData!); // Tanpa underscore
      }
    });
  }

  void setInitialData(Map<String, dynamic> itemData) {
    _nameController.text = itemData["name"] ?? "";
    _quantityController.text = itemData["quantity"].toString();
    _codeController.text = itemData["code"] ?? "";
    _selectedBrand = itemData["brand"];
    setState(() {}); // Update UI
  }

  Future<void> _fetchBrands() async {
    final String apiUrl = "${dotenv.env['BASE_URL']}/api/barang/brands";
    try {
      // 🔥 Ambil token Firebase
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print("🔴 Gagal mendapatkan token Firebase.");
        throw Exception("Gagal mendapatkan token.");
      }

      // 🔵 Request ke backend dengan token
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // ✅ Kirim token
        },
      );

      print("🟡 Response dari server: ${response.statusCode}");
      print("🟡 Body response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> brandList = json.decode(response.body);

        setState(() {
          _brands.clear(); // 🔄 Hindari data duplikat
          _brands.addAll(brandList.map((brand) => brand['name'].toString()));

          // 🔥 Atur dropdown agar default ke pilihan pertama jika kosong
          if (_brands.isNotEmpty &&
              (_selectedBrand == null || !_brands.contains(_selectedBrand))) {
            _selectedBrand = _brands.first;
          }

          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load brands");
      }
    } catch (e) {
      print("🔴 Error saat mengambil brands: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? getFormData() {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _selectedBrand == null) {
      return null;
    }

    return {
      "name": _nameController.text,
      "quantity": int.tryParse(_quantityController.text) ?? 0,
      "code": _codeController.text,
      "brand": _selectedBrand,
    };
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 2, color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(width: 2, color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 2, color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration("Nama Barang"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Jumlah"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: _inputDecoration("Kode"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: _inputDecoration("Merk"),
                  items: _brands.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  },
                ),
              ],
            ),
          );
  }
}
