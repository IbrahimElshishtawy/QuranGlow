import 'package:flutter/material.dart';
import 'package:quranglow/core/theme/theme_controller.dart';

enum AudioDownloadMode { fullSurah, selectedAyat }

class AppSettings {
  final ThemeMode themeMode;
  final double fontScale;
  final String readerEditionId;
  final String fontFamily;
  final AppColorScheme colorScheme;
  final AudioDownloadMode audioDownloadMode;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    required this.fontScale,
    required this.readerEditionId,
    this.fontFamily = 'System',
    this.colorScheme = AppColorScheme.green,
    this.audioDownloadMode = AudioDownloadMode.fullSurah,
  });

  bool get darkMode => themeMode == ThemeMode.dark;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    String? readerEditionId,
    String? fontFamily,
    AppColorScheme? colorScheme,
    AudioDownloadMode? audioDownloadMode,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    fontScale: fontScale ?? this.fontScale,
    readerEditionId: readerEditionId ?? this.readerEditionId,
    fontFamily: fontFamily ?? this.fontFamily,
    colorScheme: colorScheme ?? this.colorScheme,
    audioDownloadMode: audioDownloadMode ?? this.audioDownloadMode,
  );
}
