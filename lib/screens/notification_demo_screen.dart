// ---------------------------------------------------
// lib/features/utils_menu/screens/notification_demo_screen.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:ta_teori/services/notification_service.dart';

class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({super.key});

  void _scheduleTestNotification(BuildContext context) {
    final notificationService = NotificationService();

    notificationService.scheduleNotification(
      id: 1,
      title: 'Reminder Anime!',
      body: 'Jangan lupa nonton episode terbaru Attack on Titan!',
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dijadwalkan! Cek dalam 5 detik.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Notifikasi Lokal'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active,
                  size: 60, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Tes Notifikasi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Klik tombol di bawah untuk menjadwalkan notifikasi tes yang akan muncul dalam 5 detik, bahkan jika aplikasi ditutup.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                onPressed: () => _scheduleTestNotification(context),
                child: const Text('Jadwalkan Notifikasi (5 Detik)'),
              )
            ],
          ),
        ),
      ),
    );
  }
}