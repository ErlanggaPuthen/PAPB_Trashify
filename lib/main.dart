import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trashify_mobile/screens/main_screen.dart'; // Import MainScreen
import 'auth/login.dart';
import 'auth/register.dart';

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
      ),
      home: SignInPage(),
      routes: {
        '/main': (context) => MainScreen(),
        '/login': (context) => SignInPage(),
        '/register': (context) => SignUpPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
