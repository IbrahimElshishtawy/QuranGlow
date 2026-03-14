import 'package:flutter/material.dart';
import 'package:quranglow/core/model/setting/adhan_sound.dart';
import 'package:quranglow/core/service/setting/daily_reminder_kind.dart';
import 'package:quranglow/core/theme/theme_controller.dart';

enum AudioDownloadMode { fullSurah, selectedAyat }

class AppSettings {
  final ThemeMode? _themeMode;
  final double fontScale;
  final String readerEditionId;
  final String fontFamily;
  final AppColorScheme colorScheme;
  final AudioDownloadMode audioDownloadMode;
  final int tasbihTarget;
  final bool tasbihVibrate;
  final bool tasbihSound;
  final String adhanSoundId;
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final DailyReminderKind dailyReminderKind;
  final bool salawatEnabled;
  final int salawatIntervalMinutes;
  final bool prayerNotificationsEnabled;

  const AppSettings({
    ThemeMode? themeMode,
    required this.fontScale,
    required this.readerEditionId,
    this.fontFamily = 'System',
    this.colorScheme = AppColorScheme.green,
    this.audioDownloadMode = AudioDownloadMode.fullSurah,
    this.tasbihTarget = 33,
    this.tasbihVibrate = true,
    this.tasbihSound = false,
    this.adhanSoundId = 'makkah',
    this.dailyReminderEnabled = false,
    this.dailyReminderHour = 7,
    this.dailyReminderMinute = 30,
    this.dailyReminderKind = DailyReminderKind.quran,
    this.salawatEnabled = false,
    this.salawatIntervalMinutes = 5,
    this.prayerNotificationsEnabled = false,
  }) : _themeMode = themeMode;

  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  bool get darkMode => themeMode == ThemeMode.dark;
  AdhanSoundOption get adhanSound => AdhanSounds.byId(adhanSoundId);
  TimeOfDay get dailyReminderTime =>
      TimeOfDay(hour: dailyReminderHour, minute: dailyReminderMinute);

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    String? readerEditionId,
    String? fontFamily,
    AppColorScheme? colorScheme,
    AudioDownloadMode? audioDownloadMode,
    int? tasbihTarget,
    bool? tasbihVibrate,
    bool? tasbihSound,
    String? adhanSoundId,
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    DailyReminderKind? dailyReminderKind,
    bool? salawatEnabled,
    int? salawatIntervalMinutes,
    bool? prayerNotificationsEnabled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    fontScale: fontScale ?? this.fontScale,
    readerEditionId: readerEditionId ?? this.readerEditionId,
    fontFamily: fontFamily ?? this.fontFamily,
    colorScheme: colorScheme ?? this.colorScheme,
    audioDownloadMode: audioDownloadMode ?? this.audioDownloadMode,
    tasbihTarget: tasbihTarget ?? this.tasbihTarget,
    tasbihVibrate: tasbihVibrate ?? this.tasbihVibrate,
    tasbihSound: tasbihSound ?? this.tasbihSound,
    adhanSoundId: adhanSoundId ?? this.adhanSoundId,
    dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
    dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
    dailyReminderKind: dailyReminderKind ?? this.dailyReminderKind,
    salawatEnabled: salawatEnabled ?? this.salawatEnabled,
    salawatIntervalMinutes:
        salawatIntervalMinutes ?? this.salawatIntervalMinutes,
    prayerNotificationsEnabled:
        prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
  );
}
