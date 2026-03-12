import 'package:flutter/material.dart';

class AboutContactTile extends StatelessWidget {
  const AboutContactTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
    this.onOpen,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onCopy;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  if (onOpen != null) ...[
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('فتح الرابط'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'نسخ',
              onPressed: onCopy,
              icon: const Icon(Icons.content_copy_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
