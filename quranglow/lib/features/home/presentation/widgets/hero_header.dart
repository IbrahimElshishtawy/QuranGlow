import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primary.withValues(alpha: 0.22),
            cs.tertiary.withValues(alpha: 0.14),
            cs.surface,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -48,
            right: -28,
            child: _GlowOrb(
              size: 170,
              color: cs.primary.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            bottom: -56,
            left: -18,
            child: _GlowOrb(
              size: 150,
              color: cs.tertiary.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 22,
              color: cs.primary.withValues(alpha: 0.30),
            ),
          ),
          Positioned(
            top: 24,
            right: 78,
            child: Icon(
              Icons.menu_book_rounded,
              size: 20,
              color: cs.primary.withValues(alpha: 0.24),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _HeaderActionButton(
                        icon: Icons.menu_rounded,
                        tooltip: 'القائمة',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.primary.withValues(alpha: 0.95),
                              cs.primary.withValues(alpha: 0.72),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: cs.onPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QuranGlow',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'رحلة يومية أهدأ مع القرآن والتدبر',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 15,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ورد اليوم',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اقرأ، استمع، تابع أهدافك، وانتقل سريعًا إلى أكثر ما تحتاجه من الصفحة الرئيسية.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: cs.primary),
      ),
    );
  }
}
