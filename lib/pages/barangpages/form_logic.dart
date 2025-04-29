import 'package:flutter/material.dart';

class FormBarangLogic {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  void setInitialData(Map<String, dynamic> itemData) {
    print("🟢 setInitialData called with itemData: $itemData");

    nameController.text = itemData["name"] ?? "";
    quantityController.text = itemData["quantity"]?.toString() ?? "";
    codeController.text = itemData["code"] ?? "";
    brandController.text = itemData["brand"] ?? "";

    // Debug log to check initial values
    print("🟢 Initial values set:");
    print("🔷 Name: ${nameController.text}");
    print("🔢 Quantity: ${quantityController.text}");
    print("🔑 Code: ${codeController.text}");
    print("🏷 Brand: ${brandController.text}");
  }

  Map<String, dynamic>? getFormData() {
    print("🔵 Form Data Validation:");
    print("🔷 Name: ${nameController.text}");
    print("🔢 Quantity: ${quantityController.text}");
    print("🔑 Code: ${codeController.text}");
    print("🏷 Brand: ${brandController.text}");

    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        codeController.text.isEmpty ||
        brandController.text.isEmpty) {
      print("🔴 Form validation failed: Missing fields");
      return null; // Validation failed
    }

    return {
      "name": nameController.text,
      "quantity": int.tryParse(quantityController.text) ?? 0,
      "code": codeController.text,
      "brand": brandController.text,
    };
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    codeController.dispose();
    brandController.dispose();
  }
}
