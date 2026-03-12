import 'package:flutter/material.dart';

class AboutHeroCard extends StatelessWidget {
  const AboutHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primary.withValues(alpha: 0.20),
            cs.tertiary.withValues(alpha: 0.08),
            cs.surface,
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.96),
                  cs.primary.withValues(alpha: 0.72),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: cs.onPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QuranGlow',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تطبيق قرآني بهوية هادئة ولمسة احترافية، يوازن بين الجمال وسهولة الوصول إلى القراءة والتفسير والاستماع.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
