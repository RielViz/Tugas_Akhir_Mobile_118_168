// ---------------------------------------------------
// lib/features/profile/screens/profile_screen.dart
// ---------------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ta_teori/features/auth/bloc/auth_bloc.dart';
import 'package:ta_teori/features/utils_menu/screens/converter_screen.dart';
import 'package:ta_teori/features/saran_kesan/screens/saran_kesan_screen.dart';
import 'package:ta_teori/features/lbs_demo/screens/lbs_demo_screen.dart';
import 'package:ta_teori/features/utils_menu/screens/notification_demo_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final user = (authBloc.state as AuthAuthenticated).user;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${user.username}.jpg';
      final String permanentPath = p.join(appDir.path, fileName);

      final File newImageFile = await File(image.path).copy(permanentPath);

      authBloc.add(ProfilePictureUpdated(imagePath: newImageFile.path));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String username = 'Guest';
          String? profilePath;

          if (state is AuthAuthenticated) {
            username = state.user.username;
            profilePath = state.user.profileImagePath;
          }

          Widget profileAvatar;
          if (profilePath != null) {
            profileAvatar = CircleAvatar(
              radius: 40,
              backgroundImage: FileImage(File(profilePath)),
            );
          } else {
            profileAvatar = const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            );
          }

          return ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    _pickImage(context);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      profileAvatar,
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade900,
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                accountName: Text(
                  username,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                accountEmail: const Text('Project Akhir - 124230168'),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                ),
              ),

              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Saran dan Kesan'),
                subtitle: const Text('Berikan masukan Anda'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SaranKesanScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calculate_outlined),
                title: const Text('Konverter'),
                subtitle: const Text('Konversi Waktu & Mata Uang'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ConverterScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.gps_fixed_outlined),
                title: const Text('Demo LBS (GPS)'),
                subtitle: const Text('Menampilkan lokasi Anda saat ini'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LbsDemoScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Demo Notifikasi'),
                subtitle: const Text('Tes notifikasi lokal terjadwal'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationDemoScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutButtonPressed());
                            Navigator.of(ctx).pop();
                            
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}