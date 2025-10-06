// lib/features/ui/pages/home/sections/goals_strip.dart
// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'package:quranglow/core/model/Goal.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;

final homeGoalsCountProvider = Provider<int>((ref) => 3);

class _GoalPos {
  const _GoalPos(this.surah, this.ayahIndex);
  final int surah; // رقم السورة
  final int ayahIndex; // 0-based
}

class _GoalPosStore {
  static String _kS(Object goalId) => 'pos_${goalId.toString()}_surah';
  static String _kA(Object goalId) => 'pos_${goalId.toString()}_ayah';

  Future<_GoalPos?> load(Object goalId) async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getInt(_kS(goalId));
    final a = sp.getInt(_kA(goalId));
    if (s == null || a == null) return null;
    return _GoalPos(s, a);
  }

  Future<void> save(Object goalId, int surah, int ayahIndex) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kS(goalId), surah);
    await sp.setInt(_kA(goalId), ayahIndex);
  }

  Future<void> clear(Object goalId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kS(goalId));
    await sp.remove(_kA(goalId));
  }
}

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
            final list = goals.whereType<models.Goal>().toList(); // FIX
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

            // شريط أفقي لا يزود العرض
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
                itemBuilder: (context, i) => _GoalPill(goal: shown[i]),
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
  final models.Goal goal;

  String _toArabicDigits(int n) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => map[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 220, height: 110),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: FutureBuilder<_GoalPos?>(
          future: _GoalPosStore().load(goal.id), // FIX: بدون cast إلى int
          builder: (context, snap) {
            final pos = snap.data;
            final hasPos = pos != null;

            final surahNum = hasPos ? pos.surah : 1;
            final ayahIdx0 = hasPos ? pos.ayahIndex : 0;
            final ayahNum = ayahIdx0 + 1;
            final surahName = quran.getSurahNameArabic(surahNum);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goal.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor: cs.primary.withOpacity(.12),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasPos
                            ? '$surahName • آية ${_toArabicDigits(ayahNum)}'
                            : 'ابدأ القراءة لهذا الهدف',
                        style: TextStyle(color: cs.outline, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () async {
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
                      child: Text(
                        hasPos ? 'تابِع' : 'ابدأ',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      tooltip: 'زيادة التقدّم',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () async {
                        final svc = ref.read(di.goalsServiceProvider);
                        final list = List<models.Goal>.from(
                          await svc.listGoals(),
                        );
                        final idx = list.indexWhere((x) => x.id == goal.id);
                        if (idx != -1) {
                          final cur = list[idx];
                          list[idx] = cur.copyWith(
                            current: min(cur.target, cur.current + 1),
                          );
                          await svc.saveAll(list);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
