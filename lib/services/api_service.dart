import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000"; // Ganti dengan URL server API-mu

  // Register API
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "Akun berhasil dibuat"};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"] ?? "Terjadi kesalahan"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  // Login API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Login berhasil",
          "token": responseBody["token"] // Ambil token jika diperlukan
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"] ?? "Email atau password salah"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }
}
