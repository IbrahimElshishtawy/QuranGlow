// lib/core/theme/theme_controller.dart

// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeMode = 'theme_mode';
const _kFontScale = 'font_scale';
const _kFontFamily = 'font_family';
const _kColorScheme = 'color_scheme';

enum AppColorScheme { green, sepia, blue }

class ThemeSettings {
  final ThemeMode mode;
  final double fontScale;
  final String fontFamily;
  final AppColorScheme colorScheme;

  const ThemeSettings({
    required this.mode,
    required this.fontScale,
    required this.fontFamily,
    required this.colorScheme,
  });

  ThemeSettings copyWith({
    ThemeMode? mode,
    double? fontScale,
    String? fontFamily,
    AppColorScheme? colorScheme,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      fontScale: fontScale ?? this.fontScale,
      fontFamily: fontFamily ?? this.fontFamily,
      colorScheme: colorScheme ?? this.colorScheme,
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
          colorScheme: AppColorScheme.green,
        ),
      ) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_kThemeMode) ?? 'system';
      final fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
      final fontFamily = prefs.getString(_kFontFamily) ?? 'System';
      final colorSchemeStr = prefs.getString(_kColorScheme) ?? 'green';

      final mode = modeStr == 'light'
          ? ThemeMode.light
          : modeStr == 'dark'
          ? ThemeMode.dark
          : ThemeMode.system;

      final colorScheme = AppColorScheme.values.firstWhere(
        (e) => e.name == colorSchemeStr,
        orElse: () => AppColorScheme.green,
      );

      state = ThemeSettings(
        mode: mode,
        fontScale: fontScale,
        fontFamily: fontFamily,
        colorScheme: colorScheme,
      );
    } catch (_) {
      // keep default on error
    }
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

  Future<void> setColorScheme(AppColorScheme scheme) async {
    state = state.copyWith(colorScheme: scheme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kColorScheme, scheme.name);
  }
}
