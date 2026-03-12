import 'dart:math' as math;

import 'package:flutter/material.dart';

class QiblaArrow extends StatelessWidget {
  const QiblaArrow({super.key, required this.rotationDeg, required this.color});

  final double rotationDeg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDeg * math.pi / 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.navigation_rounded, size: 70, color: color),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.30)),
            ),
            child: Text(
              'القبلة',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
