// lib/features/ui/pages/setting/widgets/goals_section.dart

import 'package:flutter/material.dart';
import 'package:test/features/ui/routes/app_routes.dart';

import 'section_header.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          child: ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('إدارة الأهداف'),
            subtitle: const Text('إضافة/تعديل الأهداف ومتابعة التقدم'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
          ),
        ),
      ],
    );
  }
}
