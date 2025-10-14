// lib/features/ui/pages/qibla/painters/rings_painter.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RingsPainter extends CustomPainter {
  final Color color;
  const RingsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final c = size.width / 2;
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(c, c), c * i / 3, p);
    }
  }

  @override
  bool shouldRepaint(covariant RingsPainter oldDelegate) => false;
}
