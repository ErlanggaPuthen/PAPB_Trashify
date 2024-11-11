import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trashify_mobile/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String? _result;
  final ApiService _apiService = ApiService();

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
      // appBar: AppBar(
      //   title: const Text('Klasifikasi Sampah'),
      //   backgroundColor: Colors.green,
      // ),
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
                      border: Border.all(color: Color(0xff098A4E)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _selectedImage == null
                        ? Center(
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xff098A4E)),
                child: const Text('Klasifikasi Gambar'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(ImageSource.gallery), // Pilih dari galeri saat ditekan
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
