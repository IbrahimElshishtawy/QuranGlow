// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller.dart';
import 'package:rxdart/rxdart.dart';

class CombinedPositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration total; // المدة الكلّية لكل المقاطع
  CombinedPositionData(this.position, this.bufferedPosition, this.total);
}

Stream<CombinedPositionData> combinedPositionStream(AudioPlayer player) {
  // ندمج: الموضع + موضع البافر + حالة الترتيب لمعرفة الدورات السابقة
  return Rx.combineLatest3<
    Duration,
    Duration,
    SequenceState?,
    CombinedPositionData
  >(
    player.positionStream,
    player.bufferedPositionStream,
    player.sequenceStateStream,
    (position, buffered, seqState) {
      final sequence = seqState?.sequence ?? const <IndexedAudioSource>[];
      final idx = seqState?.currentIndex ?? 0;

      // مدد المقاطع (قد تكون null – نعتبرها صفر حتى تُعرف)
      final durations = sequence
          .map((s) => s.duration ?? Duration.zero)
          .toList();

      final total = durations.fold<Duration>(Duration.zero, (a, b) => a + b);
      final passed = durations
          .take(idx)
          .fold<Duration>(Duration.zero, (a, b) => a + b);

      final pos = passed + position;
      final buf = passed + buffered;

      return CombinedPositionData(pos, buf, total);
    },
  );

  StreamBuilder<CombinedPositionData>(
    stream: combinedPositionStream(player),
    builder: (_, snap) {
      final d =
          snap.data ??
          CombinedPositionData(Duration.zero, Duration.zero, Duration.zero);
      return PositionBar(
        positionStream: Stream.value(d.position),
        durationStream: Stream.value(d.total),
        bufferedStream: Stream.value(d.bufferedPosition),
        onSeek: player.seek,
      );
    },
  );
}
