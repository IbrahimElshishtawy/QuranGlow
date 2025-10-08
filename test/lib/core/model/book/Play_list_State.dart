// ignore_for_file: file_names

import 'package:just_audio/just_audio.dart';

class PlaylistState {
  final String editionId;
  final int chapter;
  final int total;
  final Stream<Duration?> durationStream;
  final Stream<Duration> positionStream;
  final Stream<Duration> bufferedStream;
  final Stream<int?> indexStream;
  final Stream<bool> playingStream;
  final Stream<LoopMode> loopModeStream;
  final Stream<double> volumeStream;

  const PlaylistState({
    required this.editionId,
    required this.chapter,
    required this.total,
    required this.durationStream,
    required this.positionStream,
    required this.bufferedStream,
    required this.indexStream,
    required this.playingStream,
    required this.loopModeStream,
    required this.volumeStream,
  });
}
