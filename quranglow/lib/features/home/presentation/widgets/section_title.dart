// lib/features/ui/pages/home/widgets/section_title.dart
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle(this.title, {super.key, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (actionText != null)
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              actionText!,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
