import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashify_mobile/screens/home_screen.dart';
import 'package:trashify_mobile/screens/hasil_riwayat_prediksi.dart';
import 'package:trashify_mobile/screens/profile.dart';
import 'package:trashify_mobile/auth/register.dart';
import 'auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyA1QVtNM9JQxVckSuxIN4Dtje1NzYloPOI',
      appId: '1:995159347289:android:4fda46401fa2b63902a148',
      messagingSenderId: '995159347289',
      projectId: 'trashify-9c313',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: TextTheme(
          titleLarge: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff03ac0e),
            ),
          ),
        ),
      ),
      home: MainScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => SignInPage(),
        '/register': (context) => SignUpPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HasilRiwayatPrediksi(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Batasan kustom tinggi top bar
        child: AppBar(
          title: Text(
            'Trashify',
            style: GoogleFonts.poppins(       //pake font poppins
              textStyle: const TextStyle(
              fontSize: 24.0,                 // ini untuk ukuran teks dipojok atas kiri
              fontWeight: FontWeight.bold,    // teksnya bold
              color: Color(0xff03ac0e),     // warna text
              )
            ),
          ),
          backgroundColor: Colors.white, // Warna top bar
          centerTitle: false, // Menempatkan title di tengah
          elevation: 3.0, // Memberikan shadow pada top bar
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
        selectedItemColor: Color(0xff03ac0e),
        onTap: _onItemTapped,
      ),
    );
  }
}
