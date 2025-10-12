// lib/main.dart
// ignore_for_file: depend_on_referenced_packages, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';

import 'core/di/providers.dart';
import 'core/theme/theme.dart';
import 'features/ui/pages/spa/splash_screen.dart';
import 'features/ui/routes/app_router.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Hive.initFlutter();
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: QuranGlowApp()));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class QuranGlowApp extends ConsumerWidget {
  const QuranGlowApp({super.key});

  static final _delegates = <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static const _locales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: 'System', fontScale: 1),
        darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: 1),
        localizationsDelegates: _delegates,       // ← add
        supportedLocales: _locales,               // ← add
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
        localizationsDelegates: _delegates,       // ← add
        supportedLocales: _locales,               // ← add
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
        localizationsDelegates: _delegates,       // ← add
        supportedLocales: _locales,               // ← add
        home: const SplashScreen(),
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
