// lib/features/ui/pages/home/sections/daily_ayah_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/daily_ayah_provider.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';

class DailyAyahCard extends ConsumerWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ayat = ref.watch(dailyAyatApiProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'آيات اليوم',
          actionText: 'تحديث',
          onAction: () => ref.refresh(dailyAyatApiProvider),
        ),
        const SizedBox(height: 8),
        ayat.when(
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
            child: Row(
              children: [
                Expanded(child: Text('تعذّر تحميل آيات اليوم: $e')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => ref.refresh(dailyAyatApiProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (list) => Container(
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = list[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.text,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: .75,
                      child: Text(a.ref, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
