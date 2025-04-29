import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DisplayBarangLogic {
  String _searchQuery = '';
  bool _isLoading = true;

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  set searchQuery(String value) => _searchQuery = value;

  Future<void> fetchData() async {
    final String apiUrl =
        "${dotenv.env['BASE_URL']}/api/barang"; // Endpoint API untuk mengambil data barang

    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print("🔴 Gagal mendapatkan token Firebase.");
        throw Exception("Gagal mendapatkan token.");
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("🟡 Response dari server: ${response.statusCode}");
      print("🟡 Body response: ${response.body}");

      if (response.statusCode == 200) {
        _isLoading = false;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("🔴 Error saat mengambil data: $e");
      _isLoading = false;
      throw e;
    }
  }

  void resetLoading() {
    _isLoading = true;
  }
}
