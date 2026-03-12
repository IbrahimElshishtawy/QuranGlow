import 'package:quranglow/core/model/setting/reader_settings.dart';
import 'package:quranglow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kDark = 'settings.dark';
  static const _kScale = 'settings.fontScale';
  static const _kReader = 'settings.readerEditionId';
  static const _kFontFamily = 'settings.fontFamily';
  static const _kColorScheme = 'settings.colorScheme';
  static const _kAudioDownloadMode = 'settings.audioDownloadMode';

  Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final dark = sp.getBool(_kDark) ?? false;
    final scale = sp.getDouble(_kScale) ?? 1.0;
    final reader = sp.getString(_kReader) ?? 'ar.alafasy';
    final fontFamily = sp.getString(_kFontFamily) ?? 'System';
    final colorSchemeStr = sp.getString(_kColorScheme) ?? 'green';
    final audioDownloadModeStr =
        sp.getString(_kAudioDownloadMode) ?? AudioDownloadMode.fullSurah.name;
    final colorScheme = AppColorScheme.values.firstWhere(
      (e) => e.name == colorSchemeStr,
      orElse: () => AppColorScheme.green,
    );
    final audioDownloadMode = AudioDownloadMode.values.firstWhere(
      (e) => e.name == audioDownloadModeStr,
      orElse: () => AudioDownloadMode.fullSurah,
    );

    return AppSettings(
      darkMode: dark,
      fontScale: scale,
      readerEditionId: reader,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      audioDownloadMode: audioDownloadMode,
    );
  }

  Future<void> setDark(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDark, v);
  }

  Future<void> setFontScale(double v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kScale, v);
  }

  Future<void> setReader(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kReader, v);
  }

  Future<void> setFontFamily(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kFontFamily, v);
  }

  Future<void> setColorScheme(AppColorScheme v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kColorScheme, v.name);
  }

  Future<void> setAudioDownloadMode(AudioDownloadMode v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAudioDownloadMode, v.name);
  }
}
