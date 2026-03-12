// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  // ── Brand palette (override with your ThemeData) ──
  static const Color _gold = Color(0xFFD4A847);
  static const Color _goldLight = Color(0xFFF0CC72);
  static const Color _midnight = Color(0xFF0D1117);
  static const Color _surface1 = Color(0xFF161C26);
  static const Color _surface2 = Color(0xFF1E2736);
  static const Color _textPrimary = Color(0xFFF0EDE6);
  static const Color _textSecondary = Color(0xFF8A96A8);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_midnight, _surface1, Color(0xFF12182B)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background: Islamic star pattern ──
              const Positioned.fill(child: _IslamicPatternBackground()),

              // ── Glow orbs ──
              Positioned(
                top: -50,
                right: -40,
                child: _GlowOrb(
                  size: 220,
                  color: _gold.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -30,
                child: _GlowOrb(
                  size: 180,
                  color: const Color(0xFF3A6EA8).withValues(alpha: 0.12),
                ),
              ),

              // ── Gold shimmer line (top border) ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _gold,
                        _goldLight,
                        _gold,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Content ──
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top bar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _MenuButton(),
                          const SizedBox(width: 12),
                          const Expanded(child: _BrandBlock()),
                          const SizedBox(width: 10),
                          const _DailyWirdPill(),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Hero cards row
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
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
        ),
      ),
    );
  }
}

// ── Islamic Geometric Pattern (pure Canvas) ──────────────────────────────────

class _IslamicPatternBackground extends StatelessWidget {
  const _IslamicPatternBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _IslamicPatternPainter());
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A847).withOpacity(0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const step = 52.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), 16, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    const points = 8;
    const inner = 0.42;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? r : r * inner;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Brand Block ───────────────────────────────────────────────────────────────

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo mark
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A847), Color(0xFF9E7520)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A847).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF0CC72), Color(0xFFD4A847)],
                ).createShader(bounds),
                child: const Text(
                  'QuranGlow',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.5,
                    color: Colors.white, // masked by shader
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'قراءة أهدأ • استماع أسهل • تنقل أسرع',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HeroHeader._textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Daily Wird Pill ───────────────────────────────────────────────────────────

class _DailyWirdPill extends StatelessWidget {
  const _DailyWirdPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: HeroHeader._gold.withValues(alpha: 0.45),
          width: 1,
        ),
        color: HeroHeader._gold.withValues(alpha: 0.08),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 13, color: HeroHeader._gold),
          SizedBox(width: 5),
          Text(
            'ورد اليوم',
            style: TextStyle(
              color: HeroHeader._gold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Button ───────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HeroHeader._gold.withValues(alpha: 0.25),
          width: 1,
        ),
        color: HeroHeader._surface2.withValues(alpha: 0.6),
      ),
      child: Builder(
        builder: (ctx) => IconButton(
          tooltip: 'القائمة',
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: const Icon(
            Icons.menu_rounded,
            color: HeroHeader._gold,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Main Hero Card ────────────────────────────────────────────────────────────

class _MainHeroCard extends StatelessWidget {
  const _MainHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: HeroHeader._gold.withValues(alpha: 0.20),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HeroHeader._surface2.withValues(alpha: 0.85),
            HeroHeader._surface1.withValues(alpha: 0.70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: HeroHeader._gold.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bismillah badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  HeroHeader._gold.withValues(alpha: 0.18),
                  HeroHeader._gold.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: HeroHeader._gold.withValues(alpha: 0.30),
                width: 0.8,
              ),
            ),
            child: const Text(
              'بسم الله الرحمن الرحيم',
              style: TextStyle(
                color: HeroHeader._gold,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Main headline
          const Text(
            'ابدأ يومك\nمع القرآن',
            style: TextStyle(
              color: HeroHeader._textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.15,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),

          // Sub headline
          const Text(
            'اقرأ واستمع وتابع أهدافك من مكان واحد.',
            style: TextStyle(
              color: HeroHeader._textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Stat chips row
          const Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.headphones_rounded,
                  label: 'استماع أسرع',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  icon: Icons.track_changes_rounded,
                  label: 'تقدم يومي',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Side Hero Card ────────────────────────────────────────────────────────────

class _SideHeroCard extends StatelessWidget {
  const _SideHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A847), Color(0xFF8A5E10)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A847).withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'ابدأ الآن',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Tags
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoldTag(label: 'مصحف'),
              const SizedBox(height: 4),
              _GoldTag(label: 'بحث'),
              const SizedBox(height: 4),
              _GoldTag(label: 'مشغل'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gold Tag (inside side card) ───────────────────────────────────────────────

class _GoldTag extends StatelessWidget {
  const _GoldTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: HeroHeader._gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HeroHeader._gold.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: HeroHeader._gold),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: HeroHeader._gold,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glow Orb ──────────────────────────────────────────────────────────────────

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
