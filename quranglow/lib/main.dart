import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/splash_screen.dart';

void main() {
  runApp(const QuranGlowApp());
}

class QuranGlowApp extends StatelessWidget {
  const QuranGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QuranGlow",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      // أول شاشة هتظهر
      home: const SplashScreen(),
      routes: {
        "/home": (context) => const HomeScreen(), // استبدلها بشاشتك الأساسية
      },
    );
  }
}

/// دي شاشة مؤقتة عشان بعد الـ Splash
/// استبدلها بالشاشة الرئيسية بتاعتك
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QuranGlow Home")),
      body: const Center(child: Text("Welcome to QuranGlow!")),
    );
  }
}
