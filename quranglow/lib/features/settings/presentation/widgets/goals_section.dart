import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/features/ui/routes/app_routes.dart';

import 'section_header.dart';

class GoalsSection extends ConsumerWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final goalsAsync = ref.watch(di.goalsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('الأهداف'),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: goalsAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.flag),
              title: Text('جاري تحميل الأهداف...'),
            ),
            error: (e, _) => ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('إدارة الأهداف'),
              subtitle: Text('تعذر تحميل البيانات: $e'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
            ),
            data: (goals) {
              final active = goals.where((g) => g.active).length;
              final reminders = goals.where((g) => g.reminderEnabled).length;
              return ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('إدارة الأهداف'),
                subtitle: Text(
                  '$active هدف مفعّل • $reminders مرتبط بإشعار • تعديل القيم والتذكيرات',
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
              );
            },
          ),
        ),
      ],
    );
  }
}
