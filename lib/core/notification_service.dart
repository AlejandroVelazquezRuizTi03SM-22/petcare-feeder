import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'petcare_reminders';
  static const String _channelName = 'Recordatorios de mascota';
  static const String _channelDescription =
      'Recordatorios de comida, agua, baño y cuidados.';

  Future<void> init() async {
    // En web no inicializamos notificaciones locales
    if (kIsWeb) {
      return;
    }

    // Configuración inicial
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      // onDidReceiveNotificationResponse: (response) {
      //   // Aquí podrías navegar a alguna pantalla al tocar la notificación
      // },
    );

    // Android 13+ permisos de notificación
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  NotificationDetails _defaultDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Programar notificación para dentro de [after] tiempo
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required Duration after,
  }) async {
    // En web no hacemos nada
    if (kIsWeb) {
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(after);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
