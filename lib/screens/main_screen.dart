import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'hasil_riwayat_prediksi.dart';
import 'profile.dart';
import 'package:trashify_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini untuk menyimpan/memuat token

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const HomeScreen(),
    HasilRiwayatPrediksi(riwayatPrediksi: []),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? ''; // Gunakan token yang tersimpan

      if (token.isEmpty) {
        _showError("Token tidak ditemukan, silakan login ulang.");
        return;
      }

      // Panggil API logout
      final response = await ApiService.logout(token); // Logout API call
      if (response['success'] == true) {
        // Hapus token dari SharedPreferences
        await prefs.remove('token');

        // Arahkan pengguna kembali ke halaman login
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        _showError(response['message'] ?? "Logout gagal");
      }
    } catch (e) {
      _showError("Gagal logout: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trashify',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff098A4E),
        onTap: _onItemTapped,
      ),
    );
  }
}
