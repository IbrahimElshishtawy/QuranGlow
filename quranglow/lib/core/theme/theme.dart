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
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.lightBgBottom,
  );

  final textTheme = GoogleFonts.scheherazadeNewTextTheme(base.textTheme);

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
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.darkBgBottom,
  );

  final textTheme = GoogleFonts.scheherazadeNewTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: true,
      elevation: 0,
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
