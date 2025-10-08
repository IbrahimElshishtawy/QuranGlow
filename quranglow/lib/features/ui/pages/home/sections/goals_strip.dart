// lib/features/ui/pages/home/sections/goals_strip.dart
// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/core/model/setting/goal.dart' as models;
import 'package:quranglow/features/ui/pages/home/sections/goal_pill.dart';
import 'package:quranglow/features/ui/pages/home/sections/goal_pos_store.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

final homeGoalsCountProvider = Provider<int>((ref) => 3);

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
            final list = goals.whereType<models.Goal>().toList();
            final shown = list.take(limit).toList();
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
                    const Expanded(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: shown.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final g = shown[i];
                  return GoalPill(
                    goal: g,
                    posStore: GoalPosStore(),
                    onFollow: (surahNum, ayahNum) async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.mushaf,
                        arguments: MushafArgs(
                          chapter: surahNum,
                          initialAyah: ayahNum,
                        ),
                      );
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    },
                    onIncreaseProgress: () async {
                      final svc = ref.read(di.goalsServiceProvider);
                      final list = List<models.Goal>.from(
                        await svc.listGoals(),
                      );
                      final idx = list.indexWhere((x) => x.id == g.id);
                      if (idx != -1) {
                        final cur = list[idx];
                        list[idx] = cur.copyWith(
                          current: min(cur.target, cur.current + 1),
                        );
                        await svc.saveAll(list);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
