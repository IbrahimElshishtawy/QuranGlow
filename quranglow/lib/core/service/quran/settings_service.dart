import 'package:flutter/material.dart';
import 'package:quranglow/core/model/setting/reader_settings.dart';
import 'package:quranglow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kThemeMode = 'settings.themeMode';
  static const _kLegacyDark = 'settings.dark';
  static const _kScale = 'settings.fontScale';
  static const _kReader = 'settings.readerEditionId';
  static const _kFontFamily = 'settings.fontFamily';
  static const _kColorScheme = 'settings.colorScheme';
  static const _kAudioDownloadMode = 'settings.audioDownloadMode';
  static const _kTasbihTarget = 'settings.tasbihTarget';
  static const _kTasbihVibrate = 'settings.tasbihVibrate';
  static const _kTasbihSound = 'settings.tasbihSound';
  static const _kAdhanSoundId = 'settings.adhanSoundId';

  Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final legacyDark = sp.getBool(_kLegacyDark) ?? false;
    final modeStr = sp.getString(_kThemeMode);
    final themeMode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => legacyDark ? ThemeMode.dark : ThemeMode.system,
    };
    final scale = sp.getDouble(_kScale) ?? 1.0;
    final reader = sp.getString(_kReader) ?? 'ar.alafasy';
    final fontFamily = sp.getString(_kFontFamily) ?? 'System';
    final colorSchemeStr = sp.getString(_kColorScheme) ?? 'green';
    final audioDownloadModeStr =
        sp.getString(_kAudioDownloadMode) ?? AudioDownloadMode.fullSurah.name;
    final tasbihTarget = sp.getInt(_kTasbihTarget) ?? 33;
    final tasbihVibrate = sp.getBool(_kTasbihVibrate) ?? true;
    final tasbihSound = sp.getBool(_kTasbihSound) ?? false;
    final adhanSoundId = sp.getString(_kAdhanSoundId) ?? 'makkah';
    final colorScheme = AppColorScheme.values.firstWhere(
      (e) => e.name == colorSchemeStr,
      orElse: () => AppColorScheme.green,
    );
    final audioDownloadMode = AudioDownloadMode.values.firstWhere(
      (e) => e.name == audioDownloadModeStr,
      orElse: () => AudioDownloadMode.fullSurah,
    );

    return AppSettings(
      themeMode: themeMode,
      fontScale: scale,
      readerEditionId: reader,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      audioDownloadMode: audioDownloadMode,
      tasbihTarget: tasbihTarget,
      tasbihVibrate: tasbihVibrate,
      tasbihSound: tasbihSound,
      adhanSoundId: adhanSoundId,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await sp.setString(_kThemeMode, value);
    await sp.setBool(_kLegacyDark, mode == ThemeMode.dark);
  }

  Future<void> setDark(bool v) async {
    await setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
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

  Future<void> setTasbihTarget(int v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kTasbihTarget, v);
  }

  Future<void> setTasbihVibrate(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kTasbihVibrate, v);
  }

  Future<void> setTasbihSound(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kTasbihSound, v);
  }

  Future<void> setAdhanSoundId(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAdhanSoundId, v);
  }
}
