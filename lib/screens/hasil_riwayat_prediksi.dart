import 'package:flutter/material.dart';

class HasilRiwayatPrediksi extends StatefulWidget {
  const HasilRiwayatPrediksi({super.key});

  @override
  _HasilRiwayatPrediksiState createState() => _HasilRiwayatPrediksiState();
}

class _HasilRiwayatPrediksiState extends State<HasilRiwayatPrediksi> {
  // Contoh data riwayat prediksi
  List<Map<String, dynamic>> riwayatPrediksi = [
    {'judul': 'Plastik', 'tanggal': '18 Okt 2024', 'status': 'Sukses'},
    {'judul': 'Kertas', 'tanggal': '17 Okt 2024', 'status': 'Gagal'},
    {'judul': 'Botol', 'tanggal': '16 Okt 2024', 'status': 'Sukses'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Prediksi'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _showDeleteAllDialog();
            },
          ),
        ],
      ),
      body: riwayatPrediksi.isEmpty
          ? Center(child: Text('Tidak ada riwayat prediksi.'))
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
                      color: item['status'] == 'Sukses' ? Colors.green : Colors.red,
                      size: 40,
                    ),
                    title: Text(
                      item['judul'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Tanggal: ${item['tanggal']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(context, item['judul'], index);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteDialog(BuildContext context, String judul, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Riwayat "$judul"?'),
          content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  riwayatPrediksi.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus semua
  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Riwayat?'),
          content: const Text('Apakah Anda yakin ingin menghapus semua riwayat prediksi?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus Semua', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  riwayatPrediksi.clear(); // Menghapus semua riwayat
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
