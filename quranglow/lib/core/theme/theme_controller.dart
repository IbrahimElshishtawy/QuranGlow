import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys
const _kThemeMode = 'theme_mode'; // 'system'|'light'|'dark'
const _kFontScale = 'font_scale'; // double as String
const _kFontFamily = 'font_family'; // String

class ThemeSettings {
  final ThemeMode mode;
  final double fontScale; // 1.0 = default, 1.1 = 10% larger, etc.
  final String fontFamily;

  const ThemeSettings({
    required this.mode,
    required this.fontScale,
    required this.fontFamily,
  });

  ThemeSettings copyWith({
    ThemeMode? mode,
    double? fontScale,
    String? fontFamily,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      fontScale: fontScale ?? this.fontScale,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeSettings>((ref) {
      return ThemeController();
    });

class ThemeController extends StateNotifier<ThemeSettings> {
  ThemeController()
    : super(
        const ThemeSettings(
          mode: ThemeMode.system,
          fontScale: 1.0,
          fontFamily: 'System',
        ),
      ) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_kThemeMode) ?? 'system';
    final fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    final fontFamily = prefs.getString(_kFontFamily) ?? 'System';
    final mode = modeStr == 'light'
        ? ThemeMode.light
        : modeStr == 'dark'
        ? ThemeMode.dark
        : ThemeMode.system;
    state = ThemeSettings(
      mode: mode,
      fontScale: fontScale,
      fontFamily: fontFamily,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    final s = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await prefs.setString(_kThemeMode, s);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
  }

  Future<void> setFontFamily(String family) async {
    state = state.copyWith(fontFamily: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamily, family);
  }
}
