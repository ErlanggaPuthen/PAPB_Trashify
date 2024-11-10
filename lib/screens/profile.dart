import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = 'Erlangga';
  String _profileUrl = '';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Memuat informasi pengguna dari penyimpanan lokal
  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Erlangga';
      _profileUrl = prefs.getString('profile_picture') ?? '';
    });
  }

  // Memilih gambar profil dan menyimpan secara lokal
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final File localImage = File('${directory.path}/profile_picture.png');
      await File(image.path).copy(localImage.path);

      // Menyimpan path gambar secara lokal
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('profile_picture', localImage.path);

      setState(() {
        _profileUrl = localImage.path;
      });
    }
  }

  // Memperbarui nama dan menyimpan di SharedPreferences
  void _updateName() async {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _name = _nameController.text;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_name', _name); // Menyimpan nama secara lokal
    }
  }

  // Logout dan menghapus data lokal
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user_name');  // Menghapus nama pengguna
    prefs.remove('profile_picture');  // Menghapus gambar profil

    Navigator.pushReplacementNamed(context, '/login'); // Pindah ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghapus tombol back
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileUrl.isNotEmpty
                          ? FileImage(File(_profileUrl))
                          : const AssetImage('assets/profile_image.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'a@gmail.com',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    title: 'Edit Name',
                    onTap: () => _showNameDialog(),
                  ),
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Security',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.help,
                    title: 'Help',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  // Dialog untuk mengedit nama pengguna
  void _showNameDialog() {
    _nameController.text = _name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateName();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
