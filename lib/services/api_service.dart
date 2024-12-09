import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini

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

        // Simpan token di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseBody["token"]);

        return {
          "success": true,
          "message": "Login berhasil",
          "token": responseBody["token"], // Ambil token jika diperlukan
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"] ?? "Email atau password salah"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  // Logout API
  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Token digunakan untuk autentikasi
        },
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Logout berhasil"};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"] ?? "Logout gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  // Get User Profile API
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/user/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Token digunakan untuk autentikasi
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          "success": true,
          "data": responseBody["data"], // Data profil pengguna
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"] ?? "Gagal memuat profil"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }
}
