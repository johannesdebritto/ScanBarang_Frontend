import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class FormBarangScreen extends StatefulWidget {
  const FormBarangScreen({super.key});

  @override
  State<FormBarangScreen> createState() => _FormBarangScreenState();
}

class _FormBarangScreenState extends State<FormBarangScreen> {
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController jumlahBarangController = TextEditingController();
  final TextEditingController kodeBarangController = TextEditingController();
  String? selectedBrand;
  final List<String> brandList = ['Brand A', 'Brand B', 'Brand C'];

  void _pickImage() {
    // Implementasi untuk upload image
  }

  void _scanQR() {
    // Implementasi untuk scan QR code
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
                const Text(
                  'Kembali',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Teks Unggah Gambar di luar kotak
                    Text(
                      'Unggah Gambar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10), // Jarak antara teks dan kotak
                    // Kotak dengan ikon upload
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Icon(
                        Iconsax.document_upload_outline,
                        size: 50,
                        color: Color(0xFF3a0ca3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nama Barang
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label di luar
                Text(
                  'Nama Barang',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4), // Jarak kecil antara label dan input
                TextField(
                  controller: namaBarangController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                          left: 4), // Geser icon ke kiri sedikit
                      child: Icon(
                        Iconsax.tag_2_outline, // Ikon yang diinginkan
                        color: Color(0xFF3a0ca3), // Warna ikon
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            // Dropdown Brand Barang
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label di luar
                Text(
                  'Brand Barang',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4), // Jarak kecil antara label dan input
                DropdownButtonFormField<String>(
                  value: selectedBrand,
                  items: brandList.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBrand = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                          left: 4), // Geser icon ke kiri sedikit
                      child: Icon(
                        Iconsax
                            .category_outline, // Ganti dengan ikon yang sesuai
                        color: Color(0xFF3a0ca3), // Warna ikon
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label di luar
                Text(
                  'Jumlah Barang',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4), // Jarak kecil antara label dan input
                TextField(
                  controller: jumlahBarangController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                          left: 4), // Geser icon ke kiri sedikit
                      child: Icon(
                        Iconsax.box_tick_outline, // Ikon angka
                        color: Color(0xFF3a0ca3), // Warna ikon
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label di luar
                Text(
                  'Kode Barang',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4), // Jarak kecil antara label dan input
                TextField(
                  controller: kodeBarangController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                          left: 4), // Geser icon ke kiri sedikit
                      child: Icon(
                        Iconsax
                            .scan_barcode_outline, // Ikon barcode untuk kode barang
                        color: Color(0xFF3a0ca3), // Warna ikon
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Scan QR Barang Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scanQR,
                icon: const Icon(Iconsax.scan_outline, color: Colors.white),
                label: const Text('Scan QR Barang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3a0ca3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implementasi submit data
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Posisikan ikon dan teks di tengah
                  children: [
                    const Icon(
                      Iconsax.document_1_outline, // Ikon yang digunakan
                      color: Colors.white,
                    ),
                    const SizedBox(
                        width: 8), // Memberi jarak antara ikon dan teks
                    const Text(
                      'Simpan Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3a0ca3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
