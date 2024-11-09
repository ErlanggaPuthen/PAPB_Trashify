import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String apiUrl = 'http://10.160.96.1:5000'; // Ganti dengan IP lokal server

  Future<Map<String, dynamic>> classifyImage(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(String.fromCharCodes(responseData));
        return result;
      } else {
        throw Exception("Failed to classify image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error connecting to the server. Check your connection and API URL.");
    }
  }
}