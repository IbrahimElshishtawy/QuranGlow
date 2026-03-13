import 'package:flutter/material.dart';
import 'package:quranglow/core/model/setting/adhan_sound.dart';
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
  }) : _themeMode = themeMode;

  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  bool get darkMode => themeMode == ThemeMode.dark;
  AdhanSoundOption get adhanSound => AdhanSounds.byId(adhanSoundId);

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
  );
}
