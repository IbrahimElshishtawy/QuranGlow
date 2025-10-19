import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

ThemeData buildLightTheme({
  String fontFamily = 'ScheherazadeNew',
  double fontScale = 1.0,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );

  final familyName = GoogleFonts.getFont(fontFamily).fontFamily!;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.lightBgBottom,
  );

  final textTheme = base.textTheme.apply(
    fontFamily: familyName,
    fontSizeFactor: fontScale,
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const StadiumBorder(),
      ),
    ),
    // اختياري: كروت حديثة (Flutter 3.22+: CardThemeData)
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

ThemeData buildDarkTheme({
  String fontFamily = 'ScheherazadeNew',
  double fontScale = 1.0,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.seedDark,
    brightness: Brightness.dark,
  );

  final familyName = GoogleFonts.getFont(fontFamily).fontFamily!;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.darkBgBottom,
  );

  final textTheme = base.textTheme.apply(
    fontFamily: familyName,
    fontSizeFactor: fontScale,
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const StadiumBorder(),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

class AppGradients {
  static LinearGradient background(Brightness b) => LinearGradient(
    colors: b == Brightness.dark
        ? const [AppColors.darkBgTop, AppColors.darkBgBottom]
        : const [AppColors.lightBgTop, AppColors.lightBgBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
