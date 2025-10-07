// lib/core/model/app_settings.dart
// ignore_for_file: file_names

class AppSettings {
  final bool darkMode;
  final double fontScale;
  final String readerEditionId;
  const AppSettings({
    required this.darkMode,
    required this.fontScale,
    required this.readerEditionId,
  });
  AppSettings copyWith({
    bool? darkMode,
    double? fontScale,
    String? readerEditionId,
  }) => AppSettings(
    darkMode: darkMode ?? this.darkMode,
    fontScale: fontScale ?? this.fontScale,
    readerEditionId: readerEditionId ?? this.readerEditionId,
  );
}
