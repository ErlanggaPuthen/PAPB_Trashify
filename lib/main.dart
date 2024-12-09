import 'package:flutter/material.dart';
import 'package:trashify_mobile/screens/main_screen.dart';
import 'package:trashify_mobile/screens/splash_screen.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const SignInPage(),
        '/register': (context) => const SignUpPage(),
        '/profile': (context) => const Profile(), // Add route for Profile
      },
      debugShowCheckedModeBanner: false,
    );
  }
}