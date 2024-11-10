import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://192.168.1.183:5000/predict';

  Future<Map<String, dynamic>> classifyImage(File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengirim gambar: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengirim gambar: $e');
    }
  }
}
