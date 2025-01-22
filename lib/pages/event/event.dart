import 'package:aplikasi_scan_barang/pages/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _namaEventController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Agar keyboard tidak menyebabkan overflow
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0052AB),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16.0),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('Kembali', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Tambahkan padding untuk keyboard
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Form Event
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF0052AB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'FORM EVENT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Form fields with uniform width
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildTextField(
                        controller: _namaEventController, label: 'Nama Event'),
                    SizedBox(height: 2),
                    buildDateField(
                        controller: _tanggalController, label: 'TANGGAL EVENT'),
                    SizedBox(height: 2),
                    buildLocationFields(
                      cityController: _cityController,
                      provinceController: _provinceController,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: buildButton(
                      color: Color(0xFF8338ec),
                      label: 'SIMPAN',
                      icon: Icons.save,
                      onPressed: () {
                        // Action for saving
                      },
                    ),
                  ),
                  SizedBox(width: 16), // Memberi jarak antara tombol
                  Expanded(
                    child: buildButton(
                      color: Color(0xFF70e000),
                      label: 'SCAN',
                      icon: Icons.qr_code_scanner,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRViewExample()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label di atas inputan
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 15, // Ukuran lebih kecil
            ),
          ),
          SizedBox(height: 4), // Jarak kecil antara label dan input
          TextField(
            controller: controller,
            style: TextStyle(fontSize: 14), // Mengatur ukuran teks inputan
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 10, // Mengurangi tinggi padding
                horizontal: 12, // Jarak dari tepi kiri/kanan
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label di atas inputan
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 15, // Ukuran lebih kecil
            ),
          ),
          SizedBox(height: 4), // Jarak kecil antara label dan input
          TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text =
                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                });
              }
            },
            style: TextStyle(fontSize: 14), // Ukuran teks input
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 10, // Tinggi padding lebih kecil
                horizontal: 12, // Jarak dari tepi kiri/kanan
              ),
              suffixIcon: Icon(Iconsax.calendar_1_outline, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Lokasi

  Widget buildLocationFields({
    required TextEditingController cityController,
    required TextEditingController provinceController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label untuk lokasi
          Text(
            'LOKASI EVENT',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 15, // Ukuran lebih kecil
            ),
          ),
          SizedBox(height: 10), // Jarak kecil antara label dan input
          Row(
            children: [
              // Input Kota/Kabupaten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label di luar
                    Text(
                      'Kota/Kabupaten',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12, // Ukuran lebih kecil
                      ),
                    ),
                    SizedBox(height: 4), // Jarak kecil antara label dan input
                    TextField(
                      controller: cityController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16), // Jarak antar inputan

              // Input Provinsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label di luar
                    Text(
                      'Provinsi',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12, // Ukuran lebih kecil
                      ),
                    ),
                    SizedBox(height: 4), // Jarak kecil antara label dan input
                    TextField(
                      controller: provinceController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required Color color,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        minimumSize: Size(200, 60),
      ),
    );
  }
}
