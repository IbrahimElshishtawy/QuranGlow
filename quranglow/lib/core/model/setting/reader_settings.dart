import 'package:flutter/material.dart';
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
  }) : _themeMode = themeMode;

  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  bool get darkMode => themeMode == ThemeMode.dark;

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
  );
}
