// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';

class GoalsStrip extends StatelessWidget {
  const GoalsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'أهدافي',
          actionText: 'الإدارة',
          onAction: () {
            // اذهب لصفحة الأهداف
          },
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: const [
              _GoalPill(label: 'ختمة رمضان', progress: .62),
              _GoalPill(label: 'ورد اليوم', progress: .35),
              _GoalPill(label: 'حفظ جزء عمّ', progress: .12),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalPill extends StatelessWidget {
  final String label;
  final double progress;
  const _GoalPill({required this.label, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.primary.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
