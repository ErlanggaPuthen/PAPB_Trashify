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
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih gambar: $e")),
      );
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
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
        _isLoading = false;
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
