// lib/features/ui/pages/qibla/widgets/compass_dial.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/qibla/widgets/rings_painter.dart';

class CompassDial extends StatelessWidget {
  final double rotationDeg;
  final Color ringsColor;
  const CompassDial({
    super.key,
    required this.rotationDeg,
    required this.ringsColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Transform.rotate(
      angle: -rotationDeg * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 8,
              child: Icon(Icons.arrow_drop_up, size: 36, color: cs.error),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              child: CustomPaint(painter: RingsPainter(ringsColor)),
            ),
          ],
        ),
      ),
    );
  }
}
