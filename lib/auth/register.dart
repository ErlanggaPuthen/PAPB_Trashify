import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String apiUrl = "http://127.0.0.1:5000/register"; // Ganti dengan URL server Anda

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": email,
            "password": password,
          }),
        );

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Akun berhasil dibuat. Silakan login.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Text(
                    'Oke',
                    style: TextStyle(color: Color(0xff098A4E)),
                  ),
                ),
              ],
            ),
          );
        } else if (response.statusCode == 400) {
          setState(() {
            _errorMessage = "Email sudah terdaftar. Gunakan email lain.";
          });
        } else {
          setState(() {
            _errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Gagal terhubung ke server.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff098A4E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: const Color(0xFFFFFFFF),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.75,
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20.0),
                      ClipOval(
                        child: Image.asset(
                          'assets/trashify.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildEmailField(),
                      const SizedBox(height: 20.0),
                      _buildPasswordField(),
                      const SizedBox(height: 20.0),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 10.0),
                      _buildErrorMessage(),
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff098A4E),
                          minimumSize: const Size(0, 48.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 8.0),
                              Text(
                                'Daftar',
                                style: TextStyle(
                                  fontFamily: 'CarthagePro',
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Sudah punya akun Trashify? ',
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Color(0xff098A4E),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        prefixIcon: const Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password harus diisi';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Konfirmasi Password',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xff098A4E), width: 2.0),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Password tidak sesuai';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return _errorMessage.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          )
        : Container();
  }
}
