import 'package:flutter/material.dart';
import 'package:quranglow/core/theme/theme_controller.dart';

ThemeData buildTheme(AppColorScheme colorScheme, bool isDark, String fontFamily, double fontScale) {
  if (isDark) return buildDarkTheme(fontFamily: fontFamily, fontScale: fontScale);

  switch (colorScheme) {
    case AppColorScheme.sepia:
      return buildSepiaTheme(fontFamily: fontFamily, fontScale: fontScale);
    case AppColorScheme.blue:
      return buildBlueTheme(fontFamily: fontFamily, fontScale: fontScale);
    case AppColorScheme.green:
    default:
      return buildLightTheme(fontFamily: fontFamily, fontScale: fontScale);
  }
}

ThemeData buildLightTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: fontFamily,
    fontSizeFactor: fontScale,
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3AB749),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 2,
    ),
  );
}

ThemeData buildSepiaTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: fontFamily,
    fontSizeFactor: fontScale,
    bodyColor: const Color(0xFF5B4636),
    displayColor: const Color(0xFF5B4636),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFFF4ECD8),
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF704214),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFDF5E6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 1,
    ),
  );
}

ThemeData buildBlueTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: fontFamily,
    fontSizeFactor: fontScale,
    bodyColor: const Color(0xFF0D47A1),
    displayColor: const Color(0xFF0D47A1),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFFE3F2FD),
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 2,
    ),
  );
}

ThemeData buildDarkTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: fontFamily,
    fontSizeFactor: fontScale,
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFF0B0B0B),
    colorScheme: base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 47, 118, 76),
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 2,
    ),
  );
}
