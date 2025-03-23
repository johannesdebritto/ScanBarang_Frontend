import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String message = '';
  Color messageColor = Colors.black;

  Future<void> sendResetPasswordLink() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': emailController.text}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        message = 'Tautan reset password telah dikirim.';
        messageColor = Colors.green; // Warna hijau untuk pesan berhasil
      });

      // Menghilangkan pesan setelah 3 detik
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          message = ''; // Menghapus pesan
          messageColor = Colors.black; // Reset warna pesan
        });
      });
    } else {
      setState(() {
        message = '${json.decode(response.body)['error']}';
        messageColor = Colors.red; // Warna merah untuk pesan kesalahan
      });

      // Menghilangkan pesan setelah 3 detik
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          message = ''; // Menghapus pesan
          messageColor = Colors.black; // Reset warna pesan
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2567E8), Color(0xFF1CE6DA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Teks Judul
                Text(
                  'Masukkan email Anda untuk\nmendapatkan tautan reset password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    // Menggunakan font Inter dari Google Fonts
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),
                // Input email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Tombol Kirim Tautan
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: sendResetPasswordLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Warna tombol
                          foregroundColor: Colors.white, // Warna tulisan
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Kirim Tautan Reset Password'),
                      ),

                const SizedBox(height: 10),
                // Tombol kembali
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Warna ungu
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Kembali'),
                ),
                const SizedBox(height: 15),
                // Pesan hasil
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      color: messageColor, // Warna pesan
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
