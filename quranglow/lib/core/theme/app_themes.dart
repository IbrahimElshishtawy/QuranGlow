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
    appBarTheme: _buildAppBarTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    filledButtonTheme: _buildFilledButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    outlinedButtonTheme: _buildOutlinedButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    floatingActionButtonTheme: _buildFabTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    iconButtonTheme: _buildIconButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 51, 96, 56),
      secondary: const Color(0xFF2E7D32),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
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
    appBarTheme: _buildAppBarTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    filledButtonTheme: _buildFilledButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    outlinedButtonTheme: _buildOutlinedButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    floatingActionButtonTheme: _buildFabTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    iconButtonTheme: _buildIconButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF704214),
      secondary: const Color(0xFF8B4513),
      surface: const Color(0xFFFDF5E6),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
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
    appBarTheme: _buildAppBarTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    filledButtonTheme: _buildFilledButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    outlinedButtonTheme: _buildOutlinedButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    floatingActionButtonTheme: _buildFabTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
    iconButtonTheme: _buildIconButtonTheme(base.colorScheme.copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF2196F3),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    )),
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
    appBarTheme: _buildAppBarTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    )),
    filledButtonTheme: _buildFilledButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    )),
    outlinedButtonTheme: _buildOutlinedButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    )),
    floatingActionButtonTheme: _buildFabTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    )),
    iconButtonTheme: _buildIconButtonTheme(base.colorScheme.copyWith(
      primary: const Color.fromARGB(166, 35, 134, 35),
      secondary: const Color.fromARGB(255, 14, 121, 59),
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      brightness: Brightness.dark,
    )),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 2,
    ),
  );
}

AppBarTheme _buildAppBarTheme(ColorScheme scheme) {
  return AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 82,
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: scheme.onSurface,
      fontSize: 23,
      fontWeight: FontWeight.w900,
    ),
    iconTheme: IconThemeData(color: scheme.primary),
    actionsIconTheme: IconThemeData(color: scheme.primary),
    shape: Border(
      bottom: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.55),
      ),
    ),
  );
}

FilledButtonThemeData _buildFilledButtonTheme(ColorScheme scheme) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      foregroundColor: scheme.onPrimary,
      backgroundColor: scheme.primary,
      disabledBackgroundColor: scheme.surfaceContainerHighest,
      disabledForegroundColor: scheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme scheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      foregroundColor: scheme.primary,
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    ),
  );
}

FloatingActionButtonThemeData _buildFabTheme(ColorScheme scheme) {
  return FloatingActionButtonThemeData(
    elevation: 0,
    highlightElevation: 0,
    foregroundColor: scheme.onPrimary,
    backgroundColor: scheme.primary,
    extendedTextStyle: const TextStyle(fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

IconButtonThemeData _buildIconButtonTheme(ColorScheme scheme) {
  return IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: scheme.primary,
      iconSize: 22,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
