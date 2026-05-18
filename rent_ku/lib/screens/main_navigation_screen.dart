import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/transaksi_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<String> _titles = ['RentKU Katalog', 'Riwayat Sewa', 'Profil Saya'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () => auth.logout(),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(showAppBar: false),
          const HistoryScreen(showAppBar: false),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade900.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isUpdating = false;

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _isUpdating = true);
      try {
        await context.read<AuthProvider>().updateProfile(photo: File(picked.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: user?.profilePhotoUrl != null 
                      ? NetworkImage(user!.profilePhotoUrl!) 
                      : null,
                  child: user?.profilePhotoUrl == null 
                      ? const Icon(Icons.person, size: 50, color: Colors.blueAccent) 
                      : null,
                ),
              ),
              if (_isUpdating)
                const Positioned.fill(child: CircularProgressIndicator()),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUpdating ? null : _pickAndUploadImage,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Chip(
            label: Text((user?.role ?? 'user').toUpperCase()),
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildProfileItem(Icons.settings_outlined, 'Pengaturan Akun'),
          _buildProfileItem(Icons.help_outline, 'Pusat Bantuan'),
          _buildProfileItem(Icons.info_outline, 'Tentang RentKU'),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.grey.withOpacity(0.05),
        onTap: () {},
      ),
    );
  }
}
