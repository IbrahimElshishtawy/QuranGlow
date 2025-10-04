import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'section_header.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader('الأهداف'),
        ListTile(
          leading: const Icon(Icons.flag),
          title: const Text('إدارة الأهداف'),
          subtitle: const Text('إضافة/تعديل الأهداف ومتابعة التقدم'),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
        ),
      ],
    );
  }
}
