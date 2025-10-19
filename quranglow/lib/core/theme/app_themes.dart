import 'package:flutter/material.dart';

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
