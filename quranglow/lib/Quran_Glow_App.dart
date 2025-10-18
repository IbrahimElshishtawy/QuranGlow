import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/theme/app_themes.dart';
import 'package:quranglow/features/ui/pages/spa/splash_screen.dart';
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
      error: (_, __) => MaterialApp(
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
      data: (s) => MaterialApp(
        title: 'QuranGlow',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: 'System', fontScale: s.fontScale),
        darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: s.fontScale),
        themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
        localizationsDelegates: _delegates,
        supportedLocales: _locales,
        home: const SplashScreen(),
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
