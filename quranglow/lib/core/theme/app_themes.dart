import 'package:flutter/material.dart';
import 'package:quranglow/core/theme/theme_controller.dart';

ThemeData buildTheme(
  AppColorScheme colorScheme,
  bool isDark,
  String fontFamily,
  double fontScale,
) {
  if (isDark) {
    return buildDarkTheme(fontFamily: fontFamily, fontScale: fontScale);
  }

  switch (colorScheme) {
    case AppColorScheme.sepia:
      return buildSepiaTheme(fontFamily: fontFamily, fontScale: fontScale);
    case AppColorScheme.blue:
      return buildBlueTheme(fontFamily: fontFamily, fontScale: fontScale);
    case AppColorScheme.green:
      return buildLightTheme(fontFamily: fontFamily, fontScale: fontScale);
  }
}

ThemeData buildLightTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = _scaledTextTheme(
    base.textTheme.apply(
    fontFamily: fontFamily,
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
    ),
    fontScale,
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
  final textTheme = _scaledTextTheme(
    base.textTheme.apply(
    fontFamily: fontFamily,
    bodyColor: const Color(0xFF5B4636),
    displayColor: const Color(0xFF5B4636),
    ),
    fontScale,
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
  final textTheme = _scaledTextTheme(
    base.textTheme.apply(
    fontFamily: fontFamily,
    bodyColor: const Color(0xFF0D47A1),
    displayColor: const Color(0xFF0D47A1),
    ),
    fontScale,
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
  final textTheme = _scaledTextTheme(
    base.textTheme.apply(
    fontFamily: fontFamily,
    bodyColor: Colors.white,
    displayColor: Colors.white,
    ),
    fontScale,
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

TextTheme _scaledTextTheme(TextTheme t, double scale) {
  final safeScale = (scale.isFinite && scale > 0) ? scale : 1.0;
  double? scaled(double? v) => v == null ? null : (v * safeScale);
  return t.copyWith(
    displayLarge: t.displayLarge?.copyWith(fontSize: scaled(t.displayLarge?.fontSize)),
    displayMedium: t.displayMedium?.copyWith(fontSize: scaled(t.displayMedium?.fontSize)),
    displaySmall: t.displaySmall?.copyWith(fontSize: scaled(t.displaySmall?.fontSize)),
    headlineLarge: t.headlineLarge?.copyWith(fontSize: scaled(t.headlineLarge?.fontSize)),
    headlineMedium: t.headlineMedium?.copyWith(fontSize: scaled(t.headlineMedium?.fontSize)),
    headlineSmall: t.headlineSmall?.copyWith(fontSize: scaled(t.headlineSmall?.fontSize)),
    titleLarge: t.titleLarge?.copyWith(fontSize: scaled(t.titleLarge?.fontSize)),
    titleMedium: t.titleMedium?.copyWith(fontSize: scaled(t.titleMedium?.fontSize)),
    titleSmall: t.titleSmall?.copyWith(fontSize: scaled(t.titleSmall?.fontSize)),
    bodyLarge: t.bodyLarge?.copyWith(fontSize: scaled(t.bodyLarge?.fontSize)),
    bodyMedium: t.bodyMedium?.copyWith(fontSize: scaled(t.bodyMedium?.fontSize)),
    bodySmall: t.bodySmall?.copyWith(fontSize: scaled(t.bodySmall?.fontSize)),
    labelLarge: t.labelLarge?.copyWith(fontSize: scaled(t.labelLarge?.fontSize)),
    labelMedium: t.labelMedium?.copyWith(fontSize: scaled(t.labelMedium?.fontSize)),
    labelSmall: t.labelSmall?.copyWith(fontSize: scaled(t.labelSmall?.fontSize)),
  );
}
