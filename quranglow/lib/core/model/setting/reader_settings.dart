import 'package:quranglow/core/theme/theme_controller.dart';

enum AudioDownloadMode { fullSurah, selectedAyat }

class AppSettings {
  final bool darkMode;
  final double fontScale;
  final String readerEditionId;
  final String fontFamily;
  final AppColorScheme colorScheme;
  final AudioDownloadMode audioDownloadMode;

  const AppSettings({
    required this.darkMode,
    required this.fontScale,
    required this.readerEditionId,
    this.fontFamily = 'System',
    this.colorScheme = AppColorScheme.green,
    this.audioDownloadMode = AudioDownloadMode.fullSurah,
  });

  AppSettings copyWith({
    bool? darkMode,
    double? fontScale,
    String? readerEditionId,
    String? fontFamily,
    AppColorScheme? colorScheme,
    AudioDownloadMode? audioDownloadMode,
  }) => AppSettings(
    darkMode: darkMode ?? this.darkMode,
    fontScale: fontScale ?? this.fontScale,
    readerEditionId: readerEditionId ?? this.readerEditionId,
    fontFamily: fontFamily ?? this.fontFamily,
    colorScheme: colorScheme ?? this.colorScheme,
    audioDownloadMode: audioDownloadMode ?? this.audioDownloadMode,
  );
}
