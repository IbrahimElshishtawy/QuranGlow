// lib/features/ui/pages/player/widgets/position_bar.dart
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';

class PositionBar extends StatelessWidget {
  const PositionBar({
    super.key,
    required this.durationStream, // مدة الإجمالي (كل المقاطع كأنها مقطع واحد)
    required this.positionStream, // الموضع الموحّد (إزاحة عبر كل المقاطع)
    required this.onSeek, // seek إلى موضع موحّد
    this.bufferedStream, // (اختياري) موضع البافر الموحّد
  });

  final Stream<Duration?> durationStream;
  final Stream<Duration> positionStream;
  final Stream<Duration>? bufferedStream;
  final Future<void> Function(Duration) onSeek;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<Duration>(
      stream: positionStream,
      initialData: Duration.zero,
      builder: (_, posSnap) {
        final pos = posSnap.data ?? Duration.zero;

        return StreamBuilder<Duration?>(
          stream: durationStream,
          initialData: const Duration(minutes: 1),
          builder: (_, durSnap) {
            final total = durSnap.data ?? const Duration(minutes: 1);

            return StreamBuilder<Duration>(
              stream: bufferedStream ?? const Stream<Duration>.empty(),
              initialData: Duration.zero,
              builder: (_, bufSnap) {
                final buf = bufSnap.data ?? Duration.zero;

                final totalMs = total.inMilliseconds.clamp(0, 1 << 62);
                final posMs = pos.inMilliseconds.clamp(0, totalMs);
                final bufMs = math.min(buf.inMilliseconds, totalMs);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الأرقام يمين/يسار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(pos),
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(.85),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _fmt(total),
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(.55),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // شريط محترف مع طبقة "buffered"
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // buffered
                        if (bufferedStream != null)
                          _TrackBar(
                            fraction: totalMs == 0
                                ? 0
                                : bufMs.toDouble() / totalMs.toDouble(),
                            color: cs.primary.withOpacity(.25),
                          ),
                        // progress + الـThumb
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: cs.primary,
                            inactiveTrackColor: cs.primary.withOpacity(.18),
                            thumbColor: cs.primary,
                            overlayColor: cs.primary.withOpacity(.12),
                          ),
                          child: Slider(
                            value: totalMs == 0
                                ? 0
                                : posMs.toDouble() / totalMs.toDouble(),
                            onChanged: (x) => onSeek(total * x),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}

/// طبقة مسطّحة تُظهر مقدار الـbuffer على نفس المسار
class _TrackBar extends StatelessWidget {
  const _TrackBar({required this.fraction, required this.color});
  final double fraction; // 0..1
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => Container(
        height: 6,
        width: c.maxWidth * fraction.clamp(0.0, 1.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
