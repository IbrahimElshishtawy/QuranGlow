import 'package:flutter/material.dart';

class HomeSurfaceCard extends StatelessWidget {
  const HomeSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.emphasis = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            emphasis ? cs.primary.withValues(alpha: 0.12) : cs.surface,
            cs.surface.withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(
          color: emphasis
              ? cs.primary.withValues(alpha: 0.30)
              : cs.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
