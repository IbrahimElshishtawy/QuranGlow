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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 260, height: 132),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              cs.surface,
              cs.primary.withValues(alpha: .08),
            ],
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: .75)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FutureBuilder<GoalPos?>(
          future: posStore.load(goal.id),
          builder: (context, snapshot) {
            final pos = snapshot.data;
            final hasPos = pos != null;
            final surahNum = hasPos ? pos.surah : 1;
            final ayahNum = hasPos ? pos.ayahIndex + 1 : 1;
            final surahName = quran.getSurahNameArabic(surahNum);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (goal.reminderEnabled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'تذكير',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${goal.current} / ${goal.target} ${goal.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 9,
                    backgroundColor: cs.primary.withValues(alpha: .12),
                    valueColor: AlwaysStoppedAnimation(
                      goal.completed ? Colors.green : cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasPos ? '$surahName • آية $ayahNum' : 'ابدأ القراءة لهذا الهدف',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => onFollow(surahNum, ayahNum),
                        child: Text(hasPos ? 'تابع' : 'ابدأ'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'زيادة التقدم',
                      onPressed: onIncreaseProgress,
                      icon: const Icon(Icons.add_rounded),
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
