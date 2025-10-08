import 'package:flutter/material.dart';

ThemeData buildLightTheme({
  required String fontFamily,
  required double fontScale,
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: fontFamily,
    fontSizeFactor: fontScale,
  );
  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: base.colorScheme.copyWith(primary: Colors.deepPurple),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
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
  );
  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFF0B0B0B),
    colorScheme: base.colorScheme.copyWith(primary: Colors.deepPurpleAccent),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
