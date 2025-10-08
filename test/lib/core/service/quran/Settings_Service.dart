// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/core/model/setting/App_Settings.dart';

class SettingsService {
  static const _kDark = 'settings.dark';
  static const _kScale = 'settings.fontScale';
  static const _kReader = 'settings.readerEditionId';

  Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final dark = sp.getBool(_kDark) ?? false;
    final scale = sp.getDouble(_kScale) ?? 1.0;
    final reader = sp.getString(_kReader) ?? 'ar.alafasy';
    return AppSettings(
      darkMode: dark,
      fontScale: scale,
      readerEditionId: reader,
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
}
