// lib/features/ui/pages/goals/goals_page.dart
// ignore_for_file: deprecated_member_use, unnecessary_cast
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/core/model/setting/goal.dart' as models;

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final asyncGoals = ref.watch(di.goalsStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأهداف'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: asyncGoals.when(
            data: (goals) => goals.isEmpty
                ? const Center(child: Text('لا توجد أهداف بعد'))
                : ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final g = goals[i] as models.Goal;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              g.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: g.progress,
                              backgroundColor: cs.primary.withOpacity(.12),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${g.current} / ${g.target} (${(g.progress * 100).round()}%)',
                                ),
                                const Spacer(),
                                FilledButton.tonal(
                                  onPressed: () async {
                                    final svc = ref.read(
                                      di.goalsServiceProvider,
                                    );
                                    final list = List<models.Goal>.from(
                                      await svc.listGoals(),
                                    );
                                    final idx = list.indexWhere(
                                      (x) => x.id == g.id,
                                    );
                                    if (idx != -1) {
                                      final cur = list[idx];
                                      list[idx] = cur.copyWith(
                                        current: min(
                                          cur.target,
                                          cur.current + 1,
                                        ),
                                      );
                                      await svc.saveAll(list);
                                    }
                                  },
                                  child: const Text('+1'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ),
    );
  }
}
