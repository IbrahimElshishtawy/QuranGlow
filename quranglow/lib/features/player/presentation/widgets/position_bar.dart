// lib/features/ui/pages/player/widgets/position_bar.dart
// ignore_for_file: unnecessary_import

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class PositionBar extends StatelessWidget {
  const PositionBar({
    super.key,
    required this.durationStream,
    required this.positionStream,
    required this.onSeek,
    required Stream<Duration> bufferedStream,
  });

  final Stream<Duration?> durationStream;
  final Stream<Duration> positionStream;
  final Future<void> Function(Duration) onSeek;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: positionStream,
      initialData: Duration.zero,
      builder: (_, posSnap) {
        final pos = posSnap.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: durationStream,
          initialData: const Duration(minutes: 1),
          builder: (_, durSnap) {
            final dur = durSnap.data ?? const Duration(minutes: 1);
            final v = dur.inMilliseconds == 0
                ? 0.0
                : pos.inMilliseconds / dur.inMilliseconds;
            return Column(
              children: [
                Slider(
                  value: v.clamp(0.0, 1.0),
                  onChanged: (x) => onSeek(dur * x),
                ),
                Text(
                  '${_fmt(pos)} / ${_fmt(dur)}',
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}
