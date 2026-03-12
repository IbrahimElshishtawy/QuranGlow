import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(width: 12),
          const Text('جارٍ تحديد الموقع وتجهيز البوصلة...'),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.errorContainer,
        border: Border.all(color: cs.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: cs.error),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class CalibrationCard extends StatelessWidget {
  const CalibrationCard({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warn = status != 'OK';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: warn
            ? cs.tertiaryContainer.withValues(alpha: 0.7)
            : cs.primaryContainer.withValues(alpha: 0.55),
        border: Border.all(
          color: warn
              ? cs.tertiary.withValues(alpha: 0.5)
              : cs.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            warn ? Icons.tune_rounded : Icons.check_circle_rounded,
            color: warn ? cs.onTertiaryContainer : cs.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warn
                  ? 'المستشعر يحتاج معايرة، حرّك الهاتف شكل 8 وابتعد عن المعادن.'
                  : 'المستشعر جيد، الدقة مناسبة.',
              style: TextStyle(
                color: warn ? cs.onTertiaryContainer : cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
