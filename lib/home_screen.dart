import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _showImage = false;
  bool _imageUploaded = false;
  String _predictedJenis = '';
  String _predictedDescription = '';
  List<dynamic> _predictionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPredictionHistory();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Hapus semua data dari Shared Preferences (atau sesuai kebutuhan)
    // Lakukan tindakan logout lainnya yang diperlukan seperti membersihkan sesi, dll.
  }

  Future<void> _loadPredictionHistory() async {
    List<dynamic> history = await _getUserPredictionHistory();
    setState(() {
      _predictionHistory = history;
    });
  }

  Future<List<dynamic>> _getUserPredictionHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        var url = Uri.parse('http://10.0.2.2:5000/history');
        var response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return data['prediction_history'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _imageUploaded = true;
        _predictedJenis = '';
      });
    }
  }

  Future<void> _classifyImage(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        var uri = Uri.parse('http://10.0.2.2:5000/predict');
        var request = http.MultipartRequest('POST', uri);

        request.headers['Authorization'] = 'Bearer $accessToken';

        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);

          String className = data['class_name'];
          double confidence = double.parse(data['confidence']);
          String description = data['description'];

          setState(() {
            _predictedJenis =
                'Jenis: $className\nAkurasi: ${confidence.toStringAsFixed(2)}';
            _predictedDescription = '$description';
          });

          await _loadPredictionHistory(); // Memuat kembali log history setelah prediksi
        } else {
          setState(() {
            _predictedJenis = 'Terjadi kesalahan saat menghubungi server.';
          });
        }
      } else {
        setState(() {
          _predictedJenis = 'Token akses tidak tersedia.';
        });
      }
    } catch (e) {
      setState(() {
        _predictedJenis = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _imageUploaded = false;
      _predictedJenis = '';
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredictionHistory() {
    if (_predictionHistory.isEmpty) {
      return Center(
        child: Text('Tidak ada log history.'),
      );
    }

    List<dynamic> displayHistory = _predictionHistory.take(5).toList();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount:
          displayHistory.length + (_predictionHistory.length > 5 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayHistory.length && _predictionHistory.length > 5) {
          return TextButton(
            onPressed: () {
              _loadMorePredictionHistory();
            },
            child: Text('Load More'),
          );
        }

        var prediction = displayHistory[index];
        String jenisSampah = '';

        // Tambahkan penanganan khusus untuk menampilkan jenis sampah berdasarkan jenis_sampah
        switch (prediction['jenis_sampah']) {
          case 1:
            jenisSampah = 'Sampah Organik';
            break;
          case 2:
            jenisSampah = 'Sampah Anorganik';
            break;
          case 3:
            jenisSampah = '';
            break;
          case 4:
            jenisSampah = '';
            break;
          case 5:
            jenisSampah = '';
            break;
          default:
            jenisSampah = 'Unknown Jenis Sampah';
            break;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _showImage = !_showImage;
            });
          },
          child: Card(
            color: Color(0xFFffd700),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            child: ListTile(
              title: Text('$jenisSampah', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Waktu: ${prediction['waktu_prediksi']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Visibility(
                    visible: _showImage,
                    child: Image.network(
                      prediction['gambar'].replaceAll('\\', '/'),
                      width: 100, // Sesuaikan ukuran gambar
                      height: 100, // Sesuaikan ukuran gambar
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              // tambahkan informasi lain yang ingin ditampilkan di sini
            ),
          ),
        );
      },
    );
  }

  void _loadMorePredictionHistory() {
    setState(() {
      List<dynamic> remainingHistory = _predictionHistory.skip(5).toList();
      _predictionHistory = remainingHistory;
    });
  }

  Future<void> _clearPredictionHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFffd700),
          title: Text('Hapus Riwayat Prediksi'),
          content:
              Text('Apakah Anda yakin ingin menghapus semua riwayat prediksi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearHistory();
              },
              child: Text('Hapus', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        var url = Uri.parse('http://10.0.2.2:5000/clear_history');
        var response = await http.delete(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          await _loadPredictionHistory();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Gagal menghapus riwayat prediksi.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Ubah tinggi sesuai kebutuhan
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.1, // Ubah persentase sesuai kebutuhan
                child: Image.asset(
                  'assets/trashify.png', // Ganti dengan path dan nama gambar yang sesuai
                  width: 60, // Sesuaikan ukuran gambar
                  height: 60, // Sesuaikan ukuran gambar
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'T R A S H I F Y',
                    style: TextStyle(
                      fontFamily:
                          'CS Gordon Sheriff', // Pastikan font telah didaftarkan di pubspec.yaml
                      fontSize: 25.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xff81b622),
          actions: [
            IconButton(
              icon: Icon(Icons.logout), // Ganti dengan ikon logout atau ikon yang sesuai
              onPressed: () async {
                await _logout(); // Fungsi untuk logout
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        focusColor: Colors.red,
        onPressed: _scrollToTop,
        tooltip: 'Scroll to Top',
        child: Icon(Icons.keyboard_arrow_up),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              _image == null
                  ? Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 100.0,
                        color: Colors.black,
                      ),
                    )
                  : Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
              SizedBox(height: 20.0),
              Text(
                'Unggah Gambar Sampah',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CarthagePro',
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _imageUploaded
                        ? () async {
                            await _classifyImage(_image!);
                          }
                        : _showImageSourceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff59981a),
                    ),
                    child: Text(
                      _imageUploaded ? 'Lihat Gambar' : 'Unggah Gambar',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontFamily: 'CarthagePro',
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  if (_imageUploaded)
                    ElevatedButton(
                      onPressed: _clearImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff59981a),
                      ),
                      child: Text(
                        'Ganti Gambar',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontFamily: 'CarthagePro',
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.0),
              if (_predictedJenis.isNotEmpty)
                Card(
                  color: Color(0xFFffd700),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Prediksi',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            _predictedJenis,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _predictedDescription,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20.0),
              Text(
                'History Prediksi',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CarthagePro',
                ),
              ),
              SizedBox(height: 10.0),
              _buildPredictionHistory(),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: _clearPredictionHistory,
                child: Text(
                  'Clear History',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red,
                    fontFamily: 'CarthagePro',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
