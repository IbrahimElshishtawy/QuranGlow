import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  static const Color _gold = Color(0xFFD4A847);
  static const Color _goldSoft = Color(0xFFF0CC72);
  static const Color _night = Color(0xFF0C1320);
  static const Color _nightSoft = Color(0xFF162033);
  static const Color _ink = Color(0xFFF6F1E8);
  static const Color _muted = Color(0xFFB2BAC8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_night, _nightSoft, Color(0xFF101A2B)],
          stops: [0.0, 0.58, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _PatternLayer()),
          Positioned(
            top: -44,
            right: -36,
            child: _GlowOrb(
              size: compact ? 180 : 220,
              color: _gold.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -30,
            child: _GlowOrb(
              size: compact ? 140 : 180,
              color: const Color(0xFF4A6FA1).withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _gold,
                    _goldSoft,
                    _gold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                compact ? 10 : 12,
                16,
                compact ? 12 : 14,
              ),
              child: Column(
                children: [
                  _HeaderTopRow(compact: compact),
                  SizedBox(height: compact ? 12 : 14),
                  Expanded(
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 11, child: _MainHeroCard()),
                        SizedBox(width: 10),
                        Expanded(flex: 7, child: _SideHeroCard()),
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

class _HeaderTopRow extends StatelessWidget {
  const _HeaderTopRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _MenuButton(),
        const SizedBox(width: 12),
        const Expanded(child: _BrandBlock()),
        if (!compact) ...[
          const SizedBox(width: 10),
          const _DailyWirdPill(),
        ],
      ],
    );
  }
}

class _PatternLayer extends StatelessWidget {
  const _PatternLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter());
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HeroHeader._gold.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const step = 52.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), 16, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 8;
    const inner = 0.42;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final currentRadius = i.isEven ? radius : radius * inner;
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HeroHeader._gold, Color(0xFF9F741F)],
            ),
            boxShadow: [
              BoxShadow(
                color: HeroHeader._gold.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
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
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [HeroHeader._goldSoft, HeroHeader._gold],
                ).createShader(bounds),
                child: const Text(
                  'QuranGlow',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'رفيق يومي لقراءة القرآن والاستماع والتدبر',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HeroHeader._muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: HeroHeader._gold.withValues(alpha: 0.10),
        border: Border.all(color: HeroHeader._gold.withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 14, color: HeroHeader._gold),
          SizedBox(width: 6),
          Text(
            'ورد اليوم',
            style: TextStyle(
              color: HeroHeader._goldSoft,
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
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: HeroHeader._nightSoft.withValues(alpha: 0.72),
        border: Border.all(
          color: HeroHeader._gold.withValues(alpha: 0.22),
        ),
      ),
      child: Builder(
        builder: (ctx) => IconButton(
          tooltip: 'القائمة',
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: const Icon(
            Icons.menu_rounded,
            color: HeroHeader._goldSoft,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _MainHeroCard extends StatelessWidget {
  const _MainHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeroHeader._gold.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HeroHeader._nightSoft.withValues(alpha: 0.90),
            const Color(0xFF141D2D).withValues(alpha: 0.82),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: HeroHeader._gold.withValues(alpha: 0.10),
              border: Border.all(color: HeroHeader._gold.withValues(alpha: 0.24)),
            ),
            child: const Text(
              'بسم الله الرحمن الرحيم',
              style: TextStyle(
                color: HeroHeader._goldSoft,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ يومك\nمع القرآن',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: HeroHeader._ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تلاوة هادئة، وصول سريع للسور، واستمرار في وردك اليومي داخل واجهة واحدة.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: HeroHeader._muted,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.menu_book_rounded,
                  label: 'مصحف منظم',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  icon: Icons.headphones_rounded,
                  label: 'استماع أسهل',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SideHeroCard extends StatelessWidget {
  const _SideHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A847), Color(0xFF8A5E10)],
        ),
        boxShadow: [
          BoxShadow(
            color: HeroHeader._gold.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionBadge(),
          SizedBox(height: 10),
          Expanded(child: _SideHeroContent()),
        ],
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: const Icon(
        Icons.nightlight_round_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _SideHeroContent extends StatelessWidget {
  const _SideHeroContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'رحلة إيمانية',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'اقرأ وابحث واستمع بسهولة',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFFF7E8C2),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: const [
            _GoldTag(label: 'مصحف'),
            _GoldTag(label: 'تفسير'),
          ],
        ),
      ],
    );
  }
}

class _GoldTag extends StatelessWidget {
  const _GoldTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: HeroHeader._gold.withValues(alpha: 0.09),
        border: Border.all(color: HeroHeader._gold.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: HeroHeader._goldSoft),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: HeroHeader._goldSoft,
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
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
