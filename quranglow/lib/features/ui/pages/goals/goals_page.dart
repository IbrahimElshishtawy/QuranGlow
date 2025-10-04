// lib/features/ui/pages/goals/goals_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // استخدم البثّ اللحظي مع قيمة ابتدائية
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
                      final g = goals[i];
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
                                Text('${(g.progress * 100).round()}%'),
                                const Spacer(),
                                FilledButton.tonal(
                                  onPressed: () async {
                                    final next = (g.progress + 0.05).clamp(
                                      0.0,
                                      1.0,
                                    );
                                    await ref
                                        .read(di.goalsServiceProvider)
                                        .updateGoal(
                                          title: g.title,
                                          progress: next,
                                        );
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
