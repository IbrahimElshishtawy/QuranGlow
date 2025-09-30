// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: .92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    _c.forward();

    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // خلفية جراديانت متناسقة مع الثيم
    final bg = isDark
        ? [const Color(0xFF0B0F12), const Color(0xFF0B0B0B)]
        : [const Color(0xFFF7F9FB), Colors.white];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: bg,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // لمسة جلو دائرية subtle
              Align(
                alignment: const Alignment(0, -0.65),
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(isDark ? .15 : .25),
                          blurRadius: 90,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى
              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // بطاقة زجاجية حول الأنيميشن
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (isDark ? Colors.white10 : Colors.white70)
                                .withOpacity(.25),
                            border: Border.all(
                              color: cs.primary.withOpacity(.15),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ScaleTransition(
                              scale: _scale,
                              child: Lottie.asset(
                                'assets/anim/Quran.json',
                                height: 160,
                                frameRate: FrameRate.max,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // عنوان التطبيق بخط ديني وجلو طفيف
                        Text(
                          'QuranGlow',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: cs.primary.withOpacity(.25),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // سطر تعريفي خفيف
                        Opacity(
                          opacity: .8,
                          child: Text(
                            'تلاوة. تدبر. تقدّم.',
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 16,
                              color: cs.onSurface.withOpacity(.65),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // مؤشر تقدم بسيط
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: cs.primary.withOpacity(.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
