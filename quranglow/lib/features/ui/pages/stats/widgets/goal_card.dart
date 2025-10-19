// lib/features/ui/pages/stats/widgets/goal_card.dart
import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final String hint;
  final double progress;
  const GoalCard({
    super.key,
    required this.title,
    required this.hint,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Opacity(opacity: .75, child: Text(hint)),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: cs.primary.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress.clamp(0, 1) * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
