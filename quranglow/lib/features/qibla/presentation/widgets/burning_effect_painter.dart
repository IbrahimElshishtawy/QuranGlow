// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';

class BurningEffectPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final double animationValue;

  BurningEffectPainter({
    required this.rotation,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final wave = math.sin(i * 0.1 + animationValue * 2 * math.pi) * 5;
      final start = Offset(
        center.dx + (radius - 10 + wave) * math.cos(angle),
        center.dy + (radius - 10 + wave) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 5 + wave) * math.cos(angle),
        center.dy + (radius + 5 + wave) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint..strokeWidth = 2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BurningEffectPainter oldDelegate) => true;
}
