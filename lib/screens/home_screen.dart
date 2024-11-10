import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trashify_mobile/services/api_service.dart';
import 'hasil_riwayat_prediksi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _result;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _riwayatPrediksi = [];

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await _apiService.classifyImage(_selectedImage!);

      setState(() {
        _result = 'Kelas: ${result['class']} | Kepercayaan: ${result['confidence']}%';
        _riwayatPrediksi.add({
          'judul': result['class'],
          'tanggal': DateTime.now().toString(),
          'status': 'Sukses',
        });
      });
    } catch (e) {
      setState(() {
        _result = 'Terjadi kesalahan saat mengirim gambar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klasifikasi Sampah'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HasilRiwayatPrediksi(riwayatPrediksi: _riwayatPrediksi),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedImage == null
                  ? const Text('Belum ada gambar yang dipilih', style: TextStyle(fontSize: 18.0))
                  : Image.file(_selectedImage!, height: 250, width: 250),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text('Pilih Gambar dari Galeri'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Gambar dari Kamera'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 20),
              if (_selectedImage != null)
                ElevatedButton(
                  onPressed: _classifyImage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Klasifikasi Gambar'),
                ),
              const SizedBox(height: 20),
              if (_result != null)
                Text(
                  _result!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
