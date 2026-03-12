import 'package:flutter/material.dart';

class MushafPageCard extends StatelessWidget {
  const MushafPageCard({
    super.key,
    required this.header,
    required this.content,
    required this.indicator,
  });

  final Widget header;
  final Widget content;
  final Widget indicator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surface.withValues(alpha: 0.78),
            cs.surfaceContainerLowest.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 10),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 10),
            content,
            const SizedBox(height: 10),
            indicator,
          ],
        ),
      ),
    );
  }
}
