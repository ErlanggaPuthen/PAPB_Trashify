import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'screens/profile.dart';
import 'screens/main_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashify',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const SignInPage(),
        '/register': (context) => const SignUpPage(),
        '/profile': (context) => const Profile(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
