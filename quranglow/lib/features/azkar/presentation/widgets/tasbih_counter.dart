// lib/features/ui/pages/azkar/widgets/tasbih_counter.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/reader_settings.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

import 'dhikr_quick_list.dart';

class TasbihCounter extends ConsumerStatefulWidget {
  const TasbihCounter({super.key});

  @override
  ConsumerState<TasbihCounter> createState() => _TasbihCounterState();
}

class _TasbihCounterState extends ConsumerState<TasbihCounter> {
  int _count = 0;
  int _rounds = 0;
  String _selectedDhikr = DhikrQuickList.items.first;

  Future<void> _inc(AppSettings settings) async {
    setState(() {
      _count++;
      ref.read(trackingServiceProvider).incRemembrance(1);
      if (_count >= settings.tasbihTarget) {
        _rounds++;
        _count = 0;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('أُنجزت دورة $_rounds')));
      }
    });

    if (settings.tasbihVibrate) {
      HapticFeedback.lightImpact();
    }
    if (settings.tasbihSound) {
      SystemSound.play(SystemSoundType.click);
    }

    _syncTasbih(settings);
  }

  void _reset(AppSettings settings) {
    setState(() {
      _count = 0;
      _rounds = 0;
    });
    _syncTasbih(settings);
  }

  void _syncTasbih(AppSettings settings) {
    ref.read(firebaseSyncServiceProvider).syncTasbih({
      'count': _count,
      'target': settings.tasbihTarget,
      'rounds': _rounds,
      'vibrate': settings.tasbihVibrate,
      'sound': settings.tasbihSound,
      'dhikr': _selectedDhikr,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ: $error')),
      data: (settings) {
        final progress =
            (_count / settings.tasbihTarget).clamp(0.0, 1.0).toDouble();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            _HeroPanel(
              selectedDhikr: _selectedDhikr,
              count: _count,
              target: settings.tasbihTarget,
              rounds: _rounds,
              progress: progress,
              onOpenSettings: () =>
                  Navigator.pushNamed(context, AppRoutes.setting),
            ),
            const SizedBox(height: 22),
            Center(
              child: _TasbihDial(
                count: _count,
                target: settings.tasbihTarget,
                progress: progress,
                onTap: () => _inc(settings),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _InfoMetric(
                    icon: Icons.flag_rounded,
                    title: 'الهدف',
                    value: '${settings.tasbihTarget}',
                    tint: cs.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoMetric(
                    icon: settings.tasbihVibrate
                        ? Icons.vibration_rounded
                        : Icons.do_not_disturb_on_total_silence_rounded,
                    title: 'الاهتزاز',
                    value: settings.tasbihVibrate ? 'مفعل' : 'متوقف',
                    tint: cs.tertiary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoMetric(
                    icon: settings.tasbihSound
                        ? Icons.music_note_rounded
                        : Icons.volume_off_rounded,
                    title: 'الصوت',
                    value: settings.tasbihSound ? 'مفعل' : 'متوقف',
                    tint: cs.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reset(settings),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('إعادة الضبط'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _inc(settings),
                      icon: const Icon(Icons.touch_app_rounded),
                      label: const Text('سبّح الآن'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'اختر الذكر',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'بدّل الذكر الحالي وسيبقى العداد مستمراً بنفس الدورة.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            DhikrQuickList(
              selectedItem: _selectedDhikr,
              onTapItem: (item) {
                setState(() => _selectedDhikr = item);
                _syncTasbih(settings);
              },
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.selectedDhikr,
    required this.count,
    required this.target,
    required this.rounds,
    required this.progress,
    required this.onOpenSettings,
  });

  final String selectedDhikr;
  final int count;
  final int target;
  final int rounds;
  final double progress;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            cs.primary.withValues(alpha: 0.14),
            cs.tertiary.withValues(alpha: 0.10),
            cs.surface.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.primaryContainer.withValues(alpha: 0.88),
                ),
                child: Text(
                  'جلسة تسبيح',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'الإعدادات',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            selectedDhikr,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أكمل التسبيح بإيقاع هادئ وواضح مع متابعة لحظية للتقدم وعدد الدورات.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniReadout(
                  title: 'التقدم الحالي',
                  value: '$count / $target',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniReadout(
                  title: 'الدورات المكتملة',
                  value: '$rounds',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasbihDial extends StatelessWidget {
  const _TasbihDial({
    required this.count,
    required this.target,
    required this.progress,
    required this.onTap,
  });

  final int count;
  final int target;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 250),
      builder: (context, animatedProgress, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _DialPainter(
                  progress: animatedProgress,
                  trackColor: cs.surfaceContainerHighest,
                  progressColor: cs.primary,
                  glowColor: cs.primary.withValues(alpha: 0.18),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTap,
              child: Ink(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary,
                      cs.primary.withValues(alpha: 0.92),
                      cs.tertiary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.28),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من $target',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        'اضغط للتسبيح',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniReadout extends StatelessWidget {
  const _MiniReadout({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const startAngle = -1.5708;
    final sweepAngle = 6.28318 * progress;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      6.28318,
      false,
      trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.glowColor != glowColor;
  }
}
