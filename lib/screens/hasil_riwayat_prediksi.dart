import 'package:flutter/material.dart';

class HasilRiwayatPrediksi extends StatelessWidget {
  final List<Map<String, dynamic>> riwayatPrediksi;

  const HasilRiwayatPrediksi({super.key, required this.riwayatPrediksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Menghilangkan appBar
      body: riwayatPrediksi.isEmpty
          ? const Center(child: Text('Tidak ada riwayat prediksi.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: riwayatPrediksi.length,
              itemBuilder: (context, index) {
                final item = riwayatPrediksi[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(
                      item['status'] == 'Sukses' ? Icons.check_circle : Icons.error,
                      color: item['status'] == 'Sukses' ? Color(0xff098A4E) : Colors.red,
                      size: 40,
                    ),
                    title: Text(
                      'Kelas: ${item['judul']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tanggal: ${item['tanggal']}'),
                  ),
                );
              },
            ),
    );
  }
}
