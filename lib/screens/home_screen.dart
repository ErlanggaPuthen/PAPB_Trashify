import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:trashify/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddRiwayat;

  const HomeScreen({super.key, required this.onAddRiwayat});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _result;
  final ApiService _apiService = ApiService(baseUrl: 'http://172.20.10.5:5000');

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

  void _deleteImage() {
    setState(() {
      _selectedImage = null;
      _result = null;
    });
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await _apiService.classifyImage(_selectedImage!);

      setState(() {
        final int classIndex = result['class'];
        final String confidence = result['confidence'];
        final className = classIndex == 0 ? 'Organik' : 'Anorganik';

        _result = 'Kelas: $className\nKepercayaan: $confidence';

        final riwayat = {
          'judul': className,
          'tanggal': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
          'status': 'Sukses',
        };

        widget.onAddRiwayat(riwayat);
      });
    } catch (e) {
      setState(() {
        _result = 'Terjadi kesalahan: $e';

        final riwayat = {
          'judul': 'Tidak diketahui',
          'tanggal': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
          'status': 'Gagal',
        };

        widget.onAddRiwayat(riwayat);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
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
                  if (_result != null)
                    Text(
                      _result!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _classifyImage,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff098A4E), textStyle: const TextStyle(color: Colors.white)),
                child: const Text('Klasifikasi Gambar'),
              ),
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
