import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  /// Register user
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 201) {
        return {"success": true, "message": "Akun berhasil dibuat"};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"]};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {"success": true, "token": responseBody["token"]};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["message"]};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }

  /// Classify Image
  static Future<Map<String, dynamic>> classifyImage(File image) async {
    final url = Uri.parse('$baseUrl/predict');
    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return {
          "success": true,
          "class": responseBody["class"],
          "confidence": responseBody["confidence"]
        };
      } else {
        return {"success": false, "message": "Klasifikasi gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server"};
    }
  }
}
