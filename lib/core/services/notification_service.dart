// -------------------------------------------
// lib/core/services/notification_service.dart
// -------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- Inisialisasi Android ---
    final AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    // --- Inisialisasi iOS ---
    final DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Gabungkan pengaturan
    final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _notificationsPlugin.initialize(initSettings);

    // --- Minta Izin Android ---
    await _requestAndroidPermission();
  }

  Future<void> _requestAndroidPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  /// Menampilkan notifikasi terjadwal
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration,
  }) async {
    // Tentukan detail notifikasi untuk Android
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'anime_app_channel_id', // ID Channel
      'Anime App Channel', // Nama Channel
      channelDescription: 'Channel untuk notifikasi Anime App',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'notification_icon',
      playSound: true,
    );

    // Tentukan detail notifikasi untuk iOS
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Jadwalkan notifikasi
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(duration),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}