// lib/features/ui/pages/home/sections/goal_pill.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quranglow/core/model/Goal.dart' as models;
import 'goal_pos_store.dart';

typedef FollowCallback = Future<void> Function(int surahNum, int ayahNum);
typedef IncCallback = Future<void> Function();

class GoalPill extends ConsumerWidget {
  const GoalPill({
    super.key,
    required this.goal,
    required this.posStore,
    required this.onFollow,
    required this.onIncreaseProgress,
  });

  final models.Goal goal;
  final GoalPosStore posStore;
  final FollowCallback onFollow;
  final IncCallback onIncreaseProgress;

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
        child: FutureBuilder<GoalPos?>(
          future: posStore.load(goal.id),
          builder: (ctx, snap) {
            final pos = snap.data;
            final hasPos = pos != null;

            final surahNum = hasPos ? pos.surah : 1;
            final ayahIdx0 = hasPos ? pos.ayahIndex : 0;
            final ayahNum = ayahIdx0 + 1;
            final surahName = quran.getSurahNameArabic(surahNum);

            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // title
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

                // progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: LinearProgressIndicator(
                    value: goal.progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: cs.primary.withOpacity(.12),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),

                // bottom row: label + buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasPos ? '$surahName • آية ${_toArabicDigits(ayahNum)}' : 'ابدأ القراءة لهذا الهدف',
                        style: TextStyle(color: cs.outline, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      onPressed: () async => await onFollow(surahNum, ayahNum),
                      child: Text(hasPos ? 'تابِع' : 'ابدأ', style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      tooltip: 'زيادة التقدّم',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () async => await onIncreaseProgress(),
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
