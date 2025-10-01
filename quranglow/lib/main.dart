import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'features/ui/routes/app_router.dart';
import 'features/ui/routes/app_routes.dart';

void main() {
  runApp(const ProviderScope(child: QuranGlowApp()));
}

class QuranGlowApp extends StatelessWidget {
  const QuranGlowApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuranGlow',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(fontFamily: 'System', fontScale: 1),
      darkTheme: buildDarkTheme(fontFamily: 'System', fontScale: 1),
      onGenerateRoute: onGenerateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
