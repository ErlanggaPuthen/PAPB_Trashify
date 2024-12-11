import 'package:flutter/material.dart';
import 'package:trashify_mobile/services/api_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = "Memuat email...";
  final String token = "your-auth-token";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await ApiService.getUserProfile(token);
      if (response['success'] == true) {
        setState(() {
          email = response['data']['email'] ?? "Email tidak ditemukan";
        });
      } else {
        setState(() {
          email = response['message'] ?? "Gagal memuat email";
        });
      }
    } catch (e) {
      setState(() {
        email = "Gagal memuat profil: $e";
      });
    }
  }

  Future<void> _logout() async {
    try {
      final response = await ApiService.logout(token);
      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        _showError(response['message'] ?? "Logout gagal");
      }
    } catch (e) {
      _showError("Gagal logout: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              email,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
