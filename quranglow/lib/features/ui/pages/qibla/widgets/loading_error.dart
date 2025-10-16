// lib/features/ui/pages/qibla/widgets/loading_error.dart
import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(width: 12),
            const Text('جاري تحديد الموقع...'),
          ],
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cs.error),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalibrationCard extends StatelessWidget {
  final String status;
  const CalibrationCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warn = status != 'OK';
    return Card(
      color: warn ? cs.errorContainer : cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              warn ? Icons.tune : Icons.check_circle,
              color: warn ? cs.onErrorContainer : cs.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                warn
                    ? 'المستشعر يحتاج معايرة: حرّك الهاتف شكل 8 وأبعده عن المعادن/المغناطيس.'
                    : 'حالة المستشعر: ممتاز',
                style: TextStyle(
                  color: warn ? cs.onErrorContainer : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
