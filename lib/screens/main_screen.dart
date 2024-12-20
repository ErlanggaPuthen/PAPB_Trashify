import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'hasil_riwayat_prediksi.dart';
import 'profile.dart';
import 'package:trashify/services/firebase_auth_services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _riwayatPrediksi = [];

  final List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions.addAll([
      HomeScreen(
        onAddRiwayat: (riwayat) {
          setState(() {
            _riwayatPrediksi.add(riwayat);
          });
        },
      ),
      HasilRiwayatPrediksi(riwayatPrediksi: _riwayatPrediksi),
      const Profile(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      final FirebaseAuthService auth = FirebaseAuthService();
      await auth.signOut();
      Navigator.pushReplacementNamed(context, "/login");
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff098A4E),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Trashify',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
