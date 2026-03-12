// lib/features/ui/pages/mushaf/widgets/mushaf_header.dart
import 'package:flutter/material.dart';

class MushafHeader extends StatelessWidget {
  const MushafHeader({super.key, required this.surahName});
  final String surahName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              surahName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.menu_book_rounded, size: 18, color: cs.primary),
        ],
      ),
    );
  }
}
