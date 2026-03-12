// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class HomeHeroTopBar extends StatelessWidget {
  HomeHeroTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 380;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.18)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 10 : 12, 16, 10),
          child: Row(
            children: [
              const _MenuButton(),
              const SizedBox(width: 12),
              const Expanded(child: _BrandBlock()),
              if (!compact) ...[
                const SizedBox(width: 10),
                const _DailyWirdPill(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HeroHeader extends StatelessWidget {
  HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 380;

    final cardStart = cs.surface.withValues(alpha: isDark ? 0.18 : 0.12);
    final cardEnd = cs.primary.withValues(alpha: isDark ? 0.08 : 0.05);

    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _GlowOrb(
              size: compact ? 120 : 160,
              color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.08),
            ),
          ),
          Positioned(
            bottom: -36,
            left: -24,
            child: _GlowOrb(
              size: compact ? 96 : 128,
              color: cs.tertiary.withValues(alpha: isDark ? 0.14 : 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Container(
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardStart, cardEnd],
                ),
                border: Border.all(
                  color: cs.primary.withValues(alpha: isDark ? 0.14 : 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.07),
                      border: Border.all(
                        color: cs.primary.withValues(
                          alpha: isDark ? 0.24 : 0.10,
                        ),
                      ),
                    ),
                    child: Text(
                      'بسم الله الرحمن الرحيم',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    'ابدأ يومك مع القرآن',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: compact ? 20 : 22,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'واجهة هادئة وواضحة للقراءة والاستماع والرجوع السريع إلى ما يهمك يوميًا.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(icon: Icons.menu_book_rounded, label: 'مصحف'),
                      _InfoChip(
                        icon: Icons.headphones_rounded,
                        label: 'استماع',
                      ),
                      _InfoChip(
                        icon: Icons.auto_stories_rounded,
                        label: 'تفسير',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          icon: Icons.visibility_rounded,
                          label: 'قراءة أوضح',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          icon: Icons.bolt_rounded,
                          label: 'وصول أسرع',
                        ),
                      ),
                    ],
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.78),
                cs.tertiary.withValues(alpha: 0.62),
              ],
            ),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QuranGlow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'رفيق يومي لقراءة القرآن والاستماع والتدبر',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyWirdPill extends StatelessWidget {
  const _DailyWirdPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surface.withValues(alpha: isDark ? 0.56 : 0.74),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            'ورد اليوم',
            style: TextStyle(
              color: cs.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surface.withValues(alpha: isDark ? 0.54 : 0.66),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        ),
      ),
      child: Builder(
        builder: (ctx) => IconButton(
          tooltip: 'القائمة',
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: Icon(Icons.menu_rounded, color: cs.primary, size: 20),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surface.withValues(alpha: isDark ? 0.58 : 0.78),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 9,
                fontWeight: FontWeight.w800,
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
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
