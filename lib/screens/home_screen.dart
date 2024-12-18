import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:trashify/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _result;
  final ApiService _apiService = ApiService(baseUrl: 'http://192.168.100.75:5000');
  final List<Map<String, dynamic>> _riwayatPrediksi = []; // Data riwayat

  // Fungsi untuk memilih gambar dari galeri
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

  // Fungsi untuk menghapus gambar
  void _deleteImage() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
  }

  // Fungsi untuk mengklasifikasikan gambar melalui API
  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await _apiService.classifyImage(_selectedImage!);

      setState(() {
        final int classIndex = result['class'];
        final String confidence = result['confidence'];
        final className = classIndex == 0 ? 'Organik' : 'Anorganik';

        _result = 'Kelas: $className\nKepercayaan: $confidence';

        // Tambahkan ke riwayat
        _riwayatPrediksi.add({
          'judul': className,
          'tanggal': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
          'status': 'Sukses',
        });
      });
    } catch (e) {
      setState(() {
        _result = 'Terjadi kesalahan: $e';

        // Tambahkan ke riwayat dengan status gagal
        _riwayatPrediksi.add({
          'judul': 'Tidak diketahui',
          'tanggal': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
          'status': 'Gagal',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Menghilangkan appBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kotak yang mengelilingi gambar dan teks hasil klasifikasi
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Tampilkan gambar yang dipilih atau placeholder
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xff098A4E)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Text('Pilih gambar', style: TextStyle(color: Colors.grey)),
                          )
                        : Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  // Teks hasil klasifikasi
                  if (_result != null)
                    Text(
                      _result!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            // Tombol Klasifikasi Gambar
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _classifyImage,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff098A4E)),
                child: const Text('Klasifikasi Gambar'),
              ),
            // Tombol Hapus Gambar
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _deleteImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus Gambar'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(ImageSource.gallery),
        backgroundColor: Colors.green, // Pilih dari galeri saat ditekan
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
