import 'package:flutter/material.dart';

class AyahCard extends StatelessWidget {
  const AyahCard({
    super.key,
    required this.surahName,
    required this.ayah,
    required this.ayahText,
  });

  final String surahName;
  final int ayah;
  final String ayahText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primary.withValues(alpha: 0.14),
            cs.surfaceContainerHigh,
            cs.surface,
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$surahName • الآية $ayah',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              ayahText.isEmpty ? 'لا يوجد نص للآية.' : ayahText,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.95,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
