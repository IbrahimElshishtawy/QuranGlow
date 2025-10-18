// lib/core/service/setting/notification_service.dart
import 'dart:io' show Platform;
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
  static const _remindersChannelId = 'reminders_ch';

  static const _dailyId = 1001;
  static const _salawatId = 1002;

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const windowsInit = WindowsInitializationSettings(
      appName: 'QuranGlow',
      appUserModelId: '',
      guid: '',
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
      windows: windowsInit,
    );

    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        await android?.requestExactAlarmsPermission();
      } catch (_) {}
    }
  }

  Future<void> requestPermissionsIfNeededFromUI(BuildContext context) async {
    if (kIsWeb || !context.mounted) return;

    final hasUiView =
        WidgetsBinding.instance.platformDispatcher.implicitView != null;
    final isResumed =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (!hasUiView || !isResumed) return;

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        final enabled = await android?.areNotificationsEnabled();
        if (enabled != true) {
          await android?.requestNotificationsPermission();
        }
        try {
          await android?.requestExactAlarmsPermission();
        } catch (_) {}
        return;
      }

      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
        return;
      }

      if (Platform.isMacOS) {
        final mac = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        await mac?.requestPermissions(alert: true, badge: true, sound: true);
        return;
      }
    } catch (e) {
      debugPrint('[NOTIF] permission request skipped: $e');
    }
  }

  // تم الاستبدال هنا
  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestExactAlarmsPermission();
      return AndroidScheduleMode.exactAllowWhileIdle;
    } catch (e) {
      debugPrint('[NOTIF] exact alarm request failed: $e');
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay t) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      t.hour,
      t.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleDailyReminder({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    await _plugin.cancel(_dailyId);
    if (!enabled || kIsWeb) return;

    final mode = await _androidScheduleMode();

    const android = AndroidNotificationDetails(
      _dailyChannelId,
      'التذكير اليومي',
      channelDescription: 'تذكير يومي لقراءة الورد',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    await _plugin.zonedSchedule(
      _dailyId,
      'ورد اليوم',
      'حان وقت تلاوة وردك اليومي',
      _nextInstanceOf(time),
      const NotificationDetails(
        android: android,
        iOS: ios,
        macOS: mac,
        windows: win,
      ),
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSalawat({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    await _plugin.cancel(_salawatId);
    if (!enabled || kIsWeb) return;

    final mode = await _androidScheduleMode();

    const android = AndroidNotificationDetails(
      _salawatChannelId,
      'تذكير الصلاة على النبي ﷺ',
      channelDescription: 'تذكير يومي للصلاة على النبي ﷺ',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    await _plugin.zonedSchedule(
      _salawatId,
      'الصلاة على النبي ﷺ',
      'صَلِّ على النبي ﷺ الآن',
      _nextInstanceOf(time),
      const NotificationDetails(
        android: android,
        iOS: ios,
        macOS: mac,
        windows: win,
      ),
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required bool daily,
  }) async {
    await _plugin.cancel(id);
    if (kIsWeb) return;

    final mode = await _androidScheduleMode();

    const android = AndroidNotificationDetails(
      _remindersChannelId,
      'تذكيرات الأذكار',
      channelDescription: 'تذكيرات الأذكار والمواعيد التي يحددها المستخدم',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled;

    if (daily) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        when.hour,
        when.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else {
      scheduled = tz.TZDateTime.from(when, tz.local);
      if (scheduled.isBefore(now)) {
        scheduled = now.add(const Duration(seconds: 5));
      }
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: android,
        iOS: ios,
        macOS: mac,
        windows: win,
      ),
      androidScheduleMode: mode,
      matchDateTimeComponents: daily ? DateTimeComponents.time : null,
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
