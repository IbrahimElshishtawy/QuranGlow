import 'package:flutter/material.dart';

class HomeSurfaceCard extends StatelessWidget {
  const HomeSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.emphasis = false,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            emphasis
                ? cs.primary.withValues(alpha: 0.08)
                : cs.surface.withValues(alpha: 0.28),
            cs.surface.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(
          color: emphasis
              ? cs.primary.withValues(alpha: 0.22)
              : cs.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: emphasis ? 0.08 : 0.04),
            blurRadius: emphasis ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
