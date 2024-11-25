import 'package:tflite/tflite.dart';

class TFLiteService {
  // Memuat model TensorFlow Lite
  static Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_sampah.tflite", // Ganti dengan path model Anda
        labels: "assets/labels.txt",         // Ganti dengan path label Anda
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Menjalankan model pada gambar
  static Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 2, // Jumlah label yang diinginkan
        threshold: 0.5, // Ambang batas
        imageMean: 0.0, // Normalisasi gambar
        imageStd: 255.0, // Normalisasi gambar
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        return {
          "class": recognitions[0]['label'], // Nama label
          "confidence": (recognitions[0]['confidence'] * 100).toStringAsFixed(2),
        };
      }
    } catch (e) {
      print("Error classifying image: $e");
    }
    return null;
  }

  // Menutup model setelah selesai
  static Future<void> closeModel() async {
    await Tflite.close();
  }
}