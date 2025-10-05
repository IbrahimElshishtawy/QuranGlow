// lib/features/ui/pages/home/sections/goals_strip.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'package:quranglow/core/model/goal.dart';

/// عدد الأهداف التي تُعرض في الصفحة الرئيسية.
/// مبدئيًا 3. لو أضفت لاحقًا حقلًا في AppSettings (مثل homeGoalsCount)
/// استبدل هذه القيمة بقراءة من settingsProvider.
final homeGoalsCountProvider = Provider<int>((ref) {
  // final settings = ref.watch(di.settingsProvider);
  // return settings.maybeWhen(data: (s) => s.homeGoalsCount, orElse: () => 3);
  return 3;
});

class GoalsStrip extends ConsumerWidget {
  const GoalsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final goalsAsync = ref.watch(di.goalsStreamProvider);
    final limit = ref.watch(homeGoalsCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'أهدافي',
          actionText: 'الإدارة',
          onAction: () => Navigator.pushNamed(context, AppRoutes.goals),
        ),
        const SizedBox(height: 8),

        goalsAsync.when(
          loading: () => Container(
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
            ),
            child: const CircularProgressIndicator(),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.error),
            ),
            child: Text('تعذّر تحميل الأهداف: $e'),
          ),
          data: (goals) {
            final shown = goals.take(limit).toList();
            if (shown.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('لا توجد أهداف بعد — ابدأ بإضافة هدف'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.goals),
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
              ),
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: shown
                    .map((g) => _GoalPill(goal: g))
                    .toList(growable: false),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GoalPill extends ConsumerWidget {
  const _GoalPill({required this.goal});
  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: cs.primary.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: TextStyle(color: cs.outline),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'زيادة التقدّم',
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () async {
                    final newValue = (goal.progress + 0.05)
                        .clamp(0.0, 1.0)
                        .toDouble();
                    await ref
                        .read(di.goalsServiceProvider)
                        .updateGoal(title: goal.title, progress: newValue);
                    // ليس ضرورياً عمل refresh لأننا على Stream
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
