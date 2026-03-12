// lib/core/model/app_settings.dart
// ignore_for_file: file_names

import 'package:quranglow/core/theme/theme_controller.dart';

class AppSettings {
  final bool darkMode;
  final double fontScale;
  final String readerEditionId;
  final String fontFamily;
  final AppColorScheme colorScheme;

  const AppSettings({
    required this.darkMode,
    required this.fontScale,
    required this.readerEditionId,
    this.fontFamily = 'System',
    this.colorScheme = AppColorScheme.green,
  });

  AppSettings copyWith({
    bool? darkMode,
    double? fontScale,
    String? readerEditionId,
    String? fontFamily,
    AppColorScheme? colorScheme,
  }) => AppSettings(
    darkMode: darkMode ?? this.darkMode,
    fontScale: fontScale ?? this.fontScale,
    readerEditionId: readerEditionId ?? this.readerEditionId,
    fontFamily: fontFamily ?? this.fontFamily,
    colorScheme: colorScheme ?? this.colorScheme,
  );
}
