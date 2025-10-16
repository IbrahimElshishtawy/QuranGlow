// lib/features/ui/pages/qibla/qibla_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/qibla_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  Key _compassKey = UniqueKey();

  void _refreshCompass() {
    setState(() {
      _compassKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اتجاه القبلة'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'إعادة التحديث',
              icon: const Icon(Icons.refresh),
              onPressed: _refreshCompass,
            ),
          ],
        ),
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
          child: Column(children: [QiblaCompass(key: _compassKey)]),
        ),
      ),
    );
  }
}
