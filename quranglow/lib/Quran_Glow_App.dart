import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/app_settings.dart';
import 'package:quranglow/core/theme/app_themes.dart';
import 'package:quranglow/core/theme/theme_controller.dart';
import 'package:quranglow/core/widgets/error_boundary.dart';
import 'package:quranglow/features/splash/presentation/pages/splash_screen.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';

class QuranGlowApp extends ConsumerWidget {
  const QuranGlowApp({super.key});

  static final _delegates = <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const _locales = <Locale>[Locale('en'), Locale('ar')];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeData getTheme(AppSettings s, bool isDark) {
      if (isDark) {
        return buildDarkTheme(fontFamily: s.fontFamily, fontScale: s.fontScale);
      }
      switch (s.colorScheme) {
        case AppColorScheme.sepia:
          return buildSepiaTheme(
            fontFamily: s.fontFamily,
            fontScale: s.fontScale,
          );
        case AppColorScheme.blue:
          return buildBlueTheme(
            fontFamily: s.fontFamily,
            fontScale: s.fontScale,
          );
        case AppColorScheme.green:
          return buildLightTheme(
            fontFamily: s.fontFamily,
            fontScale: s.fontScale,
          );
      }
    }

    return settings.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: 'System', fontScale: 1),
        darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: 1),
        localizationsDelegates: _delegates,
        supportedLocales: _locales,
        home: const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => MaterialApp(
        title: 'QuranGlow',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: 'System', fontScale: 1),
        darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: 1),
        localizationsDelegates: _delegates,
        supportedLocales: _locales,
        home: const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Text('خطأ في تحميل الإعدادات')),
        ),
      ),
      data: (s) => GlobalErrorBoundary(
        child: MaterialApp(
          title: 'QuranGlow',
          debugShowCheckedModeBanner: false,
          theme: getTheme(s as AppSettings, false),
          darkTheme: getTheme(s as AppSettings, true),
          themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: _delegates,
          supportedLocales: _locales,
          home: const SplashScreen(),
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
  }
}
