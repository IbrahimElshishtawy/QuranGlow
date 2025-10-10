// lib/core/notifications/notification_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _dailyChannelId = 'daily_reminder_ch';
  static const _salawatChannelId = 'salawat_ch';
  static const _dailyId = 1001;
  static const _salawatId = 1002;

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Android 13+
    if (!kIsWeb) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // iOS 10+
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay t) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, t.hour, t.minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  Future<void> scheduleDailyReminder({required bool enabled, required TimeOfDay time}) async {
    await _plugin.cancel(_dailyId);
    if (!enabled || kIsWeb) return;

    const android = AndroidNotificationDetails(
      _dailyChannelId, 'التذكير اليومي',
      channelDescription: 'تذكير يومي لقراءة الورد',
      importance: Importance.high, priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      _dailyId,
      'ورد اليوم',
      'حان وقت تلاوة وردك اليومي',
      _nextInstanceOf(time),
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSalawat({required bool enabled, required TimeOfDay time}) async {
    await _plugin.cancel(_salawatId);
    if (!enabled || kIsWeb) return;

    const android = AndroidNotificationDetails(
      _salawatChannelId, 'تذكير الصلاة على النبي ﷺ',
      channelDescription: 'تذكير يومي للصلاة على النبي ﷺ',
      importance: Importance.high, priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      _salawatId,
      'الصلاة على النبي ﷺ',
      'صَلِّ على النبي ﷺ الآن',
      _nextInstanceOf(time),
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
