// lib/features/ui/pages/home/widgets/hero_header.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [cs.surface.withOpacity(.28), cs.surface]
                  : [cs.primary.withOpacity(.10), cs.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-0.9, -0.3),
          child: Icon(
            Icons.star_rounded,
            size: 42,
            color: cs.primary.withOpacity(.18),
          ),
        ),
        Align(
          alignment: const Alignment(0.85, -0.4),
          child: Icon(
            Icons.nightlight_round,
            size: 56,
            color: cs.primary.withOpacity(.16),
          ),
        ),
        Align(
          alignment: const Alignment(0, .35),
          child: Text(
            'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withOpacity(.70),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
