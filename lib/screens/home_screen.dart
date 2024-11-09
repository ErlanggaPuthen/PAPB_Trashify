import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:trashify_mobile/services/api_service.dart'; // Pastikan untuk mengimpor ApiService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _image; // Variabel untuk menyimpan gambar dalam bentuk byte
  String? _result; // Variabel untuk menyimpan hasil klasifikasi
  final ApiService _apiService = ApiService(); // Instansiasi ApiService
  XFile? _pickedFile; // Simpan file yang dipilih

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    _pickedFile = await picker.pickImage(source: source);

    if (_pickedFile != null) {
      final Uint8List imageBytes = await _pickedFile!.readAsBytes();
      setState(() {
        _image = imageBytes; // Menyimpan gambar dalam bentuk byte
        _result = null; // Reset hasil setiap kali gambar baru dipilih
      });
    }
  }

  // Fungsi untuk mengirim gambar ke server Flask API
  Future<void> _classifyImage() async {
    if (_pickedFile == null) return;

    final imageFile = File(_pickedFile!.path); // Buat File dari XFile

    try {
      // Panggil metode classifyImage dari ApiService
      final result = await _apiService.classifyImage(imageFile);

      // Dapatkan hasil klasifikasi dari respons server
      setState(() {
        _result = 'Kelas: ${result['class']} | Kepercayaan: ${result['confidence']}%';
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
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image == null
                  ? const Text(
                      'Belum ada gambar yang dipilih',
                      style: TextStyle(fontSize: 18.0),
                    )
                  : Image.memory(
                      _image!,
                      height: 250,
                      width: 250,
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text('Pilih Gambar dari Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Gambar dari Kamera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              if (_image != null)
                ElevatedButton(
                  onPressed: _classifyImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
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
