import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image; // Variabel untuk menyimpan gambar yang diupload

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _image = File(image.path); // Menyimpan gambar yang dipilih
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
      body: Center( // Membuat semua konten berada di tengah
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertikal di tengah
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontal di tengah
            children: [
              // Menampilkan gambar jika ada yang dipilih
              _image == null
                  ? const Text(
                      'Belum ada gambar yang dipilih',
                      style: TextStyle(fontSize: 18.0),
                    )
                  : Image.file(
                      _image!,
                      height: 250,
                      width: 250,
                    ),
              const SizedBox(height: 20),

              // Tombol untuk memilih gambar dari galeri
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text('Pilih Gambar dari Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 10),

              // Tombol untuk mengambil gambar dari kamera
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Gambar dari Kamera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol untuk mengirim gambar untuk klasifikasi
              if (_image != null)
                ElevatedButton(
                  onPressed: () {
                    // Implementasi fungsi klasifikasi gambar di sini
                    // Misalnya, kirim gambar ke server atau model klasifikasi
                  },
                  child: const Text('Klasifikasi Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
