// lib/features/ui/pages/player/controller/player_controller_provider.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/core/di/providers.dart';

final editionIdProvider = StateProvider<String>((_) => 'ar.alafasy');
final chapterProvider = StateProvider<int>((_) => 1);

final playerControllerProvider =
    AsyncNotifierProvider.autoDispose<PlayerController, PlaylistState>(
      PlayerController.new,
    );

class PlayerController extends AsyncNotifier<PlaylistState> {
  final _player = AudioPlayer();
  List<UriAudioSource> _tracks = const [];

  @override
  Future<PlaylistState> build() async {
    ref.onDispose(() => _player.dispose());
    final ed = ref.watch(editionIdProvider);
    final ch = ref.watch(chapterProvider);

    final service = ref.read(quranServiceProvider);
    final json = await service.getSurahAudio(ed, ch);
    final root = json['data'] ?? json;
    final List ayahs = (root['ayahs'] ?? root['verses'] ?? []) as List;

    final items = <UriAudioSource>[];
    for (final a in ayahs) {
      final m = Map<String, dynamic>.from(a as Map);
      final url = (m['audio'] ?? m['audioUrl'] ?? m['url'] ?? '').toString();
      if (url.isEmpty) continue;
      items.add(AudioSource.uri(Uri.parse(url)));
    }
    if (items.isEmpty) {
      throw Exception('لا توجد روابط صوت في هذه النسخة ($ed)');
    }

    _tracks = items;
    await _player.setAudioSource(ConcatenatingAudioSource(children: _tracks));

    return PlaylistState(
      editionId: ed,
      chapter: ch,
      total: _tracks.length,
      durationStream: _player.durationStream,
      positionStream: _player.positionStream,
      bufferedStream: _player.bufferedPositionStream,
      indexStream: _player.currentIndexStream,
      playingStream: _player.playingStream,
    );
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seekTo(Duration d) => _player.seek(d);
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();

  void changeEdition(String ed) =>
      ref.read(editionIdProvider.notifier).state = ed;

  void changeChapter(int ch) =>
      ref.read(chapterProvider.notifier).state = ch.clamp(1, 114);
}

class PlaylistState {
  final String editionId;
  final int chapter;
  final int total;
  final Stream<Duration?> durationStream;
  final Stream<Duration> positionStream;
  final Stream<Duration> bufferedStream;
  final Stream<int?> indexStream;
  final Stream<bool> playingStream;

  const PlaylistState({
    required this.editionId,
    required this.chapter,
    required this.total,
    required this.durationStream,
    required this.positionStream,
    required this.bufferedStream,
    required this.indexStream,
    required this.playingStream,
  });
}
