import 'package:flutter/material.dart';
import 'features/ui/routes/app_router.dart';
import 'features/ui/routes/app_routes.dart';

void main() => runApp(const QuranGlowApp());

class QuranGlowApp extends StatelessWidget {
  const QuranGlowApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuranGlow',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: onGenerateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
