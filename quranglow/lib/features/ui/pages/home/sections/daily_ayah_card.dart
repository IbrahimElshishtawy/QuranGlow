// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/daily_ayah_provider.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class DailyAyahCard extends ConsumerWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ayah = ref.watch(dailyAyahProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'آية اليوم',
          actionText: 'المزيد',
          onAction: () {
            Navigator.pushNamed(context, AppRoutes.ayah);
          },
        ),
        const SizedBox(height: 8),
        ayah.when(
          loading: () => Container(
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withOpacity(.20)),
            ),
            child: const CircularProgressIndicator(),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.error),
            ),
            child: Text('تعذّر تحميل آية اليوم: $e'),
          ),
          data: (d) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(.10),
                  cs.surfaceContainerHighest,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withOpacity(.20)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.text,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: .75,
                  child: Text(d.ref, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
