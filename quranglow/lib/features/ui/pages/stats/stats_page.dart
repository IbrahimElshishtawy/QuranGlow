// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final narrow = size.width < 600;

    // بيانات وهمية — اربطها لاحقًا بخدمة حقيقية من core
    const totalReading = '12:30';
    const readAyat = 520;
    const streakDays = 7;
    const sessions = 34;
    final weeklyProgress = [20, 45, 30, 60, 40, 75, 55]; // ٪ لكل يوم

    final cards = <Widget>[
      _KpiCard(
        title: 'ساعات التلاوة',
        value: totalReading,
        icon: Icons.schedule,
      ),
      _KpiCard(
        title: 'عدد الآيات المقروءة',
        value: '$readAyat',
        icon: Icons.menu_book_rounded,
      ),
      _KpiCard(
        title: 'أيام المواظبة',
        value: '$streakDays',
        icon: Icons.local_fire_department_rounded,
      ),
      _KpiCard(
        title: 'عدد الجلسات',
        value: '$sessions',
        icon: Icons.self_improvement_rounded,
      ),
      _ChartCard(title: 'التقدّم الأسبوعي', bars: weeklyProgress),
      _GoalCard(title: 'هدف هذا الشهر', hint: 'إكمال 3 أجزاء', progress: 0.62),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإحصائيات'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = w < 600 ? 2 : (w < 900 ? 3 : 4);
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
        ),
      ),
    );
  }
}

/* ------------------------------ Widgets ------------------------------ */

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cs.primary),
              ),
            ),
            const Spacer(),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Opacity(
              opacity: .8,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<int> bars; // 0..100
  const _ChartCard({required this.title, required this.bars});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final v in bars) ...[
                    Expanded(child: _MiniBar(value: v / 100.0)),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: .7,
              child: Text(
                'نسبة الإنجاز كل يوم خلال الأسبوع',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double value; // 0..1
  const _MiniBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: value.clamp(0.0, 1.0) * 120, // أقصى ارتفاع بصري
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String hint;
  final double progress; // 0..1
  const _GoalCard({
    required this.title,
    required this.hint,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Opacity(opacity: .75, child: Text(hint)),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.primary.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
