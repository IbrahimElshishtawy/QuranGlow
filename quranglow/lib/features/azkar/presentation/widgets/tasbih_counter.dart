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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    cs.primaryContainer,
                    cs.tertiaryContainer,
                    cs.surface,
                  ],
                ),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDhikr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.setting),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('الإعدادات'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'استمر بهدوء وثبات حتى تكتمل الدورة الحالية.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: cs.surface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_count / ${settings.tasbihTarget}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'الدورات المكتملة: $_rounds',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => _inc(settings),
                child: Ink(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cs.primary,
                        cs.primary.withValues(alpha: 0.92),
                        cs.tertiary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.24),
                        blurRadius: 32,
                        spreadRadius: 4,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_count',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اضغط للتسبيح',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.flag_rounded,
                    label: 'الهدف',
                    value: '${settings.tasbihTarget}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: settings.tasbihVibrate
                        ? Icons.vibration_rounded
                        : Icons.do_not_disturb_on_total_silence_rounded,
                    label: 'الاهتزاز',
                    value: settings.tasbihVibrate ? 'مفعل' : 'متوقف',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: settings.tasbihSound
                        ? Icons.music_note_rounded
                        : Icons.volume_off_rounded,
                    label: 'الصوت',
                    value: settings.tasbihSound ? 'مفعل' : 'متوقف',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reset(settings),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة الضبط'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _inc(settings),
                    icon: const Icon(Icons.touch_app_rounded),
                    label: const Text('سبّح الآن'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'أذكار سريعة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
