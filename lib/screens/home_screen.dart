import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trashify_mobile/services/api_service.dart'; // Sesuaikan nama aplikasi Anda

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage; // Gambar yang dipilih
  String? _result; // Hasil klasifikasi
  bool _isLoading = false; // Status loading untuk proses klasifikasi

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null; // Reset hasil klasifikasi saat memilih gambar baru
      });
    }
  }

  // Fungsi untuk mengirim gambar ke API dan mendapatkan hasil klasifikasi
  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true; // Set status loading
      _result = null; // Reset hasil klasifikasi
    });

    try {
      // Mengirim gambar ke API Flask
      final response = await ApiService.classifyImage(_selectedImage!);

      if (response["success"] == true) {
        setState(() {
          _result = 'Kelas: ${response["class"]} | Kepercayaan: ${response["confidence"]}%';
        });
      } else {
        setState(() {
          _result = "Gagal mengklasifikasikan gambar: ${response["message"]}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() {
        _isLoading = false; // Hentikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: _isLoading ? null : _classifyImage,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff098A4E)),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                      )
                    : const Text('Klasifikasi Gambar'),
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
