import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quranglow/core/model/setting/goal.dart' as models;

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
      constraints: const BoxConstraints.tightFor(width: 240, height: 118),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [cs.surface, cs.primary.withValues(alpha: .07)],
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: .7)),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  goal.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: LinearProgressIndicator(
                    value: goal.progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: cs.primary.withValues(alpha: .10),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasPos
                            ? '$surahName • آية ${_toArabicDigits(ayahNum)}'
                            : 'ابدأ القراءة لهذا الهدف',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () async => onFollow(surahNum, ayahNum),
                      child: Text(hasPos ? 'تابع' : 'ابدأ'),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      tooltip: 'زيادة التقدّم',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () async => onIncreaseProgress(),
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
