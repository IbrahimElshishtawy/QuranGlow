// ignore_for_file: unused_local_variable, deprecated_member_use, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/stats/controller/stats_controller.dart';
import 'package:quranglow/features/ui/pages/stats/widgets/kpi_card.dart';
import 'package:quranglow/features/ui/pages/stats/widgets/chart_card.dart';
import 'package:quranglow/features/ui/pages/stats/widgets/goal_card.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statsControllerProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(statsControllerProvider.notifier).reload(),
            ),
          ],
        ),
        body: async.when(
          loading: () => const _LoadingGrid(),
          error: (e, _) => _ErrorView(
            message: '$e',
            onRetry: () => ref.read(statsControllerProvider.notifier).reload(),
          ),
          data: (st) {
            final summary = st.summary;
            final weekly = st.weekly;
            final goal = st.goal;

            final cards = <Widget>[
              KpiCard(
                title: 'ساعات التلاوة',
                value: _fmtDuration(summary.totalReading),
                icon: Icons.schedule,
              ),
              KpiCard(
                title: 'عدد الآيات المقروءة',
                value: '${summary.readAyat}',
                icon: Icons.menu_book_rounded,
              ),
              KpiCard(
                title: 'أيام المواظبة',
                value: '${summary.streakDays}',
                icon: Icons.local_fire_department_rounded,
              ),
              KpiCard(
                title: 'عدد الجلسات',
                value: '${summary.sessions}',
                icon: Icons.self_improvement_rounded,
              ),
              ChartCard(title: 'التقدّم الأسبوعي', bars: weekly.dailyPercent),
              GoalCard(
                title: goal.title,
                hint: goal.hint,
                progress: goal.progress,
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final cross = w < 600 ? 2 : (w < 900 ? 3 : 4);
                  final narrow = w < 600;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: narrow ? .98 : 1.2,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (_, i) => cards[i],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ---------------- Views للحالات ---------------- */

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget shimmerBox() => Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cross = w < 600 ? 2 : (w < 900 ? 3 : 4);
          return GridView.builder(
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (_, __) => shimmerBox(),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ أثناء جلب البيانات',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: .8,
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('حاول مجددًا'),
            ),
          ],
        ),
      ),
    );
  }
}
