import 'package:flutter/material.dart';

class AudioLoadingState extends StatelessWidget {
  const AudioLoadingState.loading({
    super.key,
    this.message = 'جارٍ تحميل الصوت...',
  }) : icon = Icons.graphic_eq_rounded,
       title = 'جاري تجهيز التلاوة',
       description = 'نحاول جلب الروابط الصوتية. قد يستغرق ذلك قليلًا حسب سرعة الإنترنت.',
       actionLabel = null,
       onAction = null,
       isLoading = true;

  const AudioLoadingState.error({
    super.key,
    required this.message,
    this.onAction,
    this.actionLabel = 'إعادة المحاولة',
  }) : icon = Icons.wifi_tethering_error_rounded,
       title = 'تعذر تحميل الصوت',
       description = 'تحقق من الاتصال بالإنترنت ثم أعد المحاولة.',
       isLoading = false;

  const AudioLoadingState.empty({
    super.key,
    this.message = 'لا توجد ملفات أو روابط صوتية متاحة الآن.',
    this.onAction,
    this.actionLabel,
  }) : icon = Icons.audio_file_outlined,
       title = 'لا يوجد صوت متاح',
       description = 'يمكنك المحاولة مرة أخرى أو اختيار قارئ مختلف.',
       isLoading = false;

  final IconData icon;
  final String title;
  final String description;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primary.withValues(alpha: .10),
            cs.secondary.withValues(alpha: .05),
          ],
        ),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.primary.withValues(alpha: .14),
            child: isLoading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: cs.primary,
                    ),
                  )
                : Icon(icon, color: cs.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
