// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/theme.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final b = Theme.of(context).brightness;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppGradients.background(b)),
          child: Stack(
            fit: StackFit.expand,
            children: [
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
                          color: scheme.primary.withOpacity(.22),
                          blurRadius: 90,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                (b == Brightness.dark
                                        ? Colors.white10
                                        : Colors.white70)
                                    .withOpacity(.25),
                            border: Border.all(
                              color: scheme.primary.withOpacity(.15),
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
                        Text(
                          'QuranGlow',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: scheme.primary.withOpacity(.25),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: .85,
                          child: Text(
                            'تلاوة • تدبر • تقدّم',
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 16,
                              color: scheme.onSurface.withOpacity(.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: scheme.primary.withOpacity(.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.primary,
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
