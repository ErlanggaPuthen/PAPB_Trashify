import 'package:tflite/tflite_v2.dart';

class TFLiteService {
  /// Memuat model TFLite
  static Future<void> loadModel() async {
    try {
      String? result = await Tflite.loadModel(
        model: 'assets/model_sampah.tflite', // Path ke file model
        labels: 'assets/labels.txt',         // Path ke file label
      );
      print("Model loaded: $result");
    } catch (e) {
      print("Error loading model: $e");
      rethrow;
    }
  }

  /// Menjalankan klasifikasi gambar
  static Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    try {
      // Melakukan inferensi dengan model
      List<dynamic>? recognitions = await Tflite.runModelOnImage(
        path: imagePath, // Path gambar
        imageMean: 127.5, // Nilai rata-rata normalisasi gambar
        imageStd: 127.5,  // Standar deviasi normalisasi gambar
        numResults: 1,    // Ambil hanya hasil terbaik
        threshold: 0.5,   // Confidence threshold minimum
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        return {
          'class': recognitions[0]['label'],       // Kelas hasil klasifikasi
          'confidence': (recognitions[0]['confidence'] * 100).toStringAsFixed(2), // Confidence
        };
      }
    } catch (e) {
      print("Error during classification: $e");
    }
    return null;
  }

  /// Menutup model untuk membebaskan resource
  static Future<void> closeModel() async {
    await Tflite.close();
  }
}
