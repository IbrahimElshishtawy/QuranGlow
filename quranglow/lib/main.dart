// lib/main.dart  (استبدل المحتوى)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/model/goal.dart';
import 'core/di/providers.dart';
import 'core/theme/theme.dart';
import 'features/ui/routes/app_router.dart';
import 'features/ui/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GoalAdapter());
  runApp(const ProviderScope(child: QuranGlowApp()));
}

class QuranGlowApp extends ConsumerWidget {
  const QuranGlowApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      loading: () => const MaterialApp(home: SizedBox()),
      error: (_, __) => const MaterialApp(home: SizedBox()),
      data: (s) => MaterialApp(
        title: 'QuranGlow',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(fontFamily: 'System', fontScale: s.fontScale),
        darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: s.fontScale),
        themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
        onGenerateRoute: onGenerateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
