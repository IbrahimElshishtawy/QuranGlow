import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quranglow/features/qibla/presentation/widgets/rings_painter.dart';

class CompassDial extends StatelessWidget {
  const CompassDial({
    super.key,
    required this.rotationDeg,
    required this.ringsColor,
  });

  final double rotationDeg;
  final Color ringsColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Transform.rotate(
      angle: -rotationDeg * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.surface, cs.surfaceContainerHighest],
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: RingsPainter(ringsColor),
                child: const SizedBox.expand(),
              ),
            ),
            ..._cardinals(cs),
            Positioned(
              top: 10,
              child: Icon(Icons.arrow_drop_up_rounded, size: 34, color: cs.error),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _cardinals(ColorScheme cs) {
    const r = 104.0;
    const labels = [('N', 0.0), ('E', 90.0), ('S', 180.0), ('W', 270.0)];

    return labels.map((e) {
      final theta = (e.$2 - 90) * math.pi / 180;
      final x = r * math.cos(theta);
      final y = r * math.sin(theta);
      final highlight = e.$1 == 'N';
      return Transform.translate(
        offset: Offset(x, y),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlight
                ? cs.error.withValues(alpha: 0.15)
                : cs.surface.withValues(alpha: 0.8),
          ),
          child: Text(
            e.$1,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: highlight ? cs.error : cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }).toList();
  }
}
