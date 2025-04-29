import 'package:aplikasi_scan_barang/pages/barangpages/form_logic.dart';
import 'package:flutter/material.dart';

class FormBarangScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final FormBarangLogic formLogic;

  const FormBarangScreen({
    Key? key,
    this.initialData,
    required this.formLogic,
  }) : super(key: key);

  @override
  FormBarangScreenState createState() => FormBarangScreenState();
}

class FormBarangScreenState extends State<FormBarangScreen> {
  late FormBarangLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = widget.formLogic;
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialData != null) {
      _logic.setInitialData(widget.initialData!);
      // kalau mau force update UI
      setState(() {});
    }
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0052AB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0052AB), width: 2),
      ),
    );
  }

  Widget _formField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: inputType,
            decoration: _inputDecoration(hint ?? label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formField(
          label: "Nama Barang",
          controller: _logic.nameController,
          hint: "Masukkan nama barang",
        ),
        _formField(
          label: "Jumlah",
          controller: _logic.quantityController,
          inputType: TextInputType.number,
          hint: "Masukkan jumlah",
        ),
        _formField(
          label: "Kode",
          controller: _logic.codeController,
          hint: "Masukkan kode barang",
        ),
        _formField(
          label: "Brand",
          controller: _logic.brandController,
          hint: "Masukkan nama brand",
        ),
      ],
    );
  }

  // NOTE: dispose() dihapus karena FormBarangLogic dikelola dari luar
}
