// lib/features/ui/pages/qibla/qibla_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_compass.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اتجاه القبلة'), centerTitle: true),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.surface, cs.surfaceContainerHighest],
            ),
          ),
          child: Column(children: [QiblaCompass()]),
        ),
      ),
    );
  }
}
