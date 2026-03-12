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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.60)),
      ),
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
            'إذا أردت إرسال بيانات التواصل أو التعريف بالتطبيق لشخص آخر، يمكنك مشاركتها مباشرة.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
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
    );
  }
}
