import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'hasil_riwayat_prediksi.dart';
import 'package:trashify_mobile/services/firebase_auth_services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar widget yang ditampilkan berdasarkan indeks yang dipilih
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HasilRiwayatPrediksi(riwayatPrediksi: []),
    // Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final FirebaseAuthService _auth = FirebaseAuthService();
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login"); // Ganti "/login" sesuai dengan rute login Anda
  }

  // Fungsi untuk memunculkan dialog konfirmasi logout
  Future<bool> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Tutup dialog dengan hasil false
              child: const Text('Batal'),
            ),
            // Tombol Logout
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Tutup dialog dengan hasil true
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    return result ?? false; // Jika dialog ditutup tanpa memilih apa pun, anggap false
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await _confirmLogout();
        if (shouldLogout) {
          await _logout();
          return true; // Logout dan keluar dari halaman
        }
        return false; // Jangan keluar jika batal
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Trashify',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff03ac0e),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 3.0,
            actions: [
              IconButton(
                onPressed: () async {
                  final shouldLogout = await _confirmLogout();
                  if (shouldLogout) {
                    await _logout();
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
              ),
            ],
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Homescreen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat Prediksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff098A4E),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
