import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AboutShareCard extends StatelessWidget {
  const AboutShareCard({
    super.key,
    required this.shareText,
  });

  final String shareText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مشاركة بيانات المطور',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مفيد لو أردت إرسال صفحة التواصل أو بيانات المطور لشخص آخر.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Share.share(shareText),
                icon: const Icon(Icons.share_rounded),
                label: const Text('مشاركة المعلومات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
