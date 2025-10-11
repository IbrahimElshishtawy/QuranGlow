// lib/features/ui/pages/qibla/widgets/qibla_arrow.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class QiblaArrow extends StatelessWidget {
  final double rotationDeg;
  final Color color;
  const QiblaArrow({super.key, required this.rotationDeg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDeg * math.pi / 180,
      child: const Icon(Icons.navigation, size: 56),
    );
  }
}
