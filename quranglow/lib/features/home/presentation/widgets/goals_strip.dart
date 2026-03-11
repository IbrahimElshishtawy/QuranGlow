import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/core/model/setting/goal.dart' as models;
import 'package:quranglow/features/home/presentation/widgets/goal_pill.dart';
import 'package:quranglow/features/home/presentation/widgets/goal_pos_store.dart';
import 'package:quranglow/features/home/presentation/widgets/home_surface_card.dart';
import 'package:quranglow/features/home/presentation/widgets/section_title.dart';
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
          loading: () => const HomeSurfaceCard(
            child: SizedBox(
              height: 92,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => HomeSurfaceCard(
            child: Text('تعذّر تحميل الأهداف: $e'),
          ),
          data: (goals) {
            final list = goals.whereType<models.Goal>().toList();
            final shown = list.take(limit).toList();
            if (shown.isEmpty) {
              return HomeSurfaceCard(
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: cs.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('لا توجد أهداف بعد، ابدأ بإضافة هدف جديد'),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.goals),
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              );
            }

            return HomeSurfaceCard(
              child: SizedBox(
                height: 138,
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
              ),
            );
          },
        ),
      ],
    );
  }
}
