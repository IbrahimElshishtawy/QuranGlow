import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quranglow/core/service/setting/daily_reminder_kind.dart';
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

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      // Ø·Ù„Ø¨ Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© ÙŠÙƒÙÙŠ Ù„Ù„Ù…Ù‡Ø§Ù… Ø§Ù„Ø¯Ù‚ÙŠÙ‚Ø© Ø§Ù„Ù…ØªÙƒØ±Ø±Ø©
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

  // Ø«Ø§Ø¨Øª Ù„ØªÙØ§Ø¯ÙŠ ØªØºÙŠÙŠØ± Ø§Ù„Ø³Ù„ÙˆÙƒ Ø¹Ù†Ø¯ Ø§Ù„Ø¬Ø¯ÙˆÙ„Ø©
  Future<AndroidScheduleMode> _androidScheduleMode() async =>
      AndroidScheduleMode.exactAllowWhileIdle;

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
    DailyReminderKind kind = DailyReminderKind.quran,
  }) async {
    await _plugin.cancel(_dailyId);
    if (!enabled || kIsWeb) return;

    final mode = await _androidScheduleMode();

    const android = AndroidNotificationDetails(
      _dailyChannelId,
      'Ø§Ù„ØªØ°ÙƒÙŠØ± Ø§Ù„ÙŠÙˆÙ…ÙŠ',
      channelDescription: 'ØªØ°ÙƒÙŠØ± ÙŠÙˆÙ…ÙŠ Ù„Ù‚Ø±Ø§Ø¡Ø© Ø§Ù„ÙˆØ±Ø¯',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    final (title, body) = switch (kind) {
      DailyReminderKind.quran => (
        'Daily Quran Reminder',
        'Time to read your daily Quran portion.'
      ),
      DailyReminderKind.adhan => (
        'Adhan Reminder',
        'Prayer time is near. Prepare for Salah.'
      ),
      DailyReminderKind.dhikr => (
        'Dhikr Reminder',
        'Take a moment now for dhikr and reflection.'
      ),
    };

    await _plugin.zonedSchedule(
      _dailyId,
      title,
      body,
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
    DailyReminderKind kind = DailyReminderKind.quran,
  }) async {
    await _plugin.cancel(_salawatId);
    if (!enabled || kIsWeb) return;

    final mode = await _androidScheduleMode();

    const android = AndroidNotificationDetails(
      _salawatChannelId,
      'ØªØ°ÙƒÙŠØ± Ø§Ù„ØµÙ„Ø§Ø© Ø¹Ù„Ù‰ Ø§Ù„Ù†Ø¨ÙŠ ï·º',
      channelDescription: 'ØªØ°ÙƒÙŠØ± ÙŠÙˆÙ…ÙŠ Ù„Ù„ØµÙ„Ø§Ø© Ø¹Ù„Ù‰ Ø§Ù„Ù†Ø¨ÙŠ ï·º',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    await _plugin.zonedSchedule(
      _salawatId,
      'Ø§Ù„ØµÙ„Ø§Ø© Ø¹Ù„Ù‰ Ø§Ù„Ù†Ø¨ÙŠ ï·º',
      'ØµÙŽÙ„Ù‘Ù Ø¹Ù„Ù‰ Ø§Ù„Ù†Ø¨ÙŠ ï·º Ø§Ù„Ø¢Ù†',
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
      'ØªØ°ÙƒÙŠØ±Ø§Øª Ø§Ù„Ø£Ø°ÙƒØ§Ø±',
      channelDescription: 'ØªØ°ÙƒÙŠØ±Ø§Øª Ø§Ù„Ø£Ø°ÙƒØ§Ø± ÙˆØ§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯ Ø§Ù„ØªÙŠ ÙŠØ­Ø¯Ø¯Ù‡Ø§ Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      showWhen: true,
      enableVibration: true,
      playSound: true,
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

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const android = AndroidNotificationDetails(
      _remindersChannelId,
      'تذكيرات الأذكار',
      channelDescription: 'تذكيرات الأذكار والمواعيد التي يحددها المستخدم',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    const mac = DarwinNotificationDetails();
    const win = WindowsNotificationDetails();

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: android,
        iOS: ios,
        macOS: mac,
        windows: win,
      ),
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}


