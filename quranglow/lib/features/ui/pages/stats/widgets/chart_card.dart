// lib/features/ui/pages/stats/widgets/chart_card.dart
import 'package:flutter/material.dart';
import 'mini_bar.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final List<int> bars;
  const ChartCard({super.key, required this.title, required this.bars});

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
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final v in bars) ...[
                    Expanded(child: MiniBar(value: v.clamp(0, 100) / 100.0)),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: .7,
              child: Text(
                'نسبة الإنجاز كل يوم خلال الأسبوع',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
