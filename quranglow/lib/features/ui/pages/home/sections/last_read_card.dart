import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class LastReadCard extends StatelessWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'متابعة القراءة',
          actionText: 'فتح',
          onAction: () {
            Navigator.pushNamed(context, AppRoutes.mushaf);
          },
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book, color: cs.primary, size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'آخر موضع: سورة البقرة • آية 255',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.mushaf),
                child: const Text('تابِع'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
