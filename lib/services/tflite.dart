import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class TFLiteService {
  late Interpreter _interpreter;

  /// Memuat model TFLite dari folder assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model_sampah.tflite');
      print("Model berhasil dimuat.");
    } catch (e) {
      print("Gagal memuat model: $e");
      rethrow;
    }
  }

  /// Menjalankan klasifikasi pada gambar
  Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    try {
      // Memuat gambar dari path
      final bytes = await File(imagePath).readAsBytes(); // Baca file sebagai bytes
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print("Gambar tidak valid.");
        return null;
      }

      // Ubah ukuran gambar sesuai input tensor model (misalnya 224x224)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // Normalisasi gambar ke format float32
      List<List<List<double>>> input = _imageToFloat32(resizedImage);

      // Inisialisasi output sesuai ukuran tensor keluaran
      var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      // Melakukan inferensi
      _interpreter.run(input, output);

      print("Hasil inferensi: $output");

      return {
        'class': output[0][0] > output[0][1] ? 'Organik' : 'Anorganik',
        'confidence': output[0][0] > output[0][1]
            ? output[0][0].toStringAsFixed(2)
            : output[0][1].toStringAsFixed(2),
      };
    } catch (e) {
      print("Gagal melakukan klasifikasi: $e");
      return null;
    }
  }

  /// Menutup interpreter untuk membebaskan resource
  void closeModel() {
    _interpreter.close();
    print("Interpreter ditutup.");
  }

  /// Konversi gambar ke format normalisasi float32
  List<List<List<double>>> _imageToFloat32(img.Image image) {
    int width = image.width;
    int height = image.height;

    // Buat tensor 3D berisi nilai float
    List<List<List<double>>> convertedImage = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          // Ambil nilai piksel sebagai objek Pixel
          final pixel = image.getPixelSafe(x, y);

          // Ekstraksi channel warna (R, G, B) menggunakan metode pada Pixel
          num red = pixel.r;
          num green = pixel.g;
          num blue = pixel.b;

          // Normalisasi nilai channel ke rentang [-1, 1]
          return [
            (red - 127.5) / 127.5,
            (green - 127.5) / 127.5,
            (blue - 127.5) / 127.5,
          ];
        },
      ),
    );
    return convertedImage;
  }
}
