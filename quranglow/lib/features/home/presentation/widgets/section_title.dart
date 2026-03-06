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
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText!, style: TextStyle(color: cs.primary)),
          ),
      ],
    );
  }
}
