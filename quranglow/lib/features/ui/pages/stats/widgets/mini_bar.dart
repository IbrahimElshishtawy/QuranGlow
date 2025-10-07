// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MiniBar extends StatelessWidget {
  final double value; // 0..1
  const MiniBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: value.clamp(0.0, 1.0) * 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
