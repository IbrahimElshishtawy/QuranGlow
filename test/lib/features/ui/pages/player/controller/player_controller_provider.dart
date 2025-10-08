// lib/features/ui/pages/player/controller/player_controller_provider.dart
// ignore_for_file: unnecessary_this

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/Play_list_State.dart';

final editionIdProvider = StateProvider<String>((_) => 'ar.alafasy');
final chapterProvider = StateProvider<int>((_) => 1);

final playerControllerProvider =
    StateNotifierProvider.autoDispose<
      PlayerController,
      AsyncValue<PlaylistState>
    >((ref) => PlayerController(ref));

class PlayerController extends StateNotifier<AsyncValue<PlaylistState>> {
  PlayerController(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;
  final _player = AudioPlayer();
  final List<AudioSource> _tracks = <AudioSource>[];

  String _currentEdition = 'ar.alafasy';
  int _currentChapter = 1;
  double _lastVolume = 1.0;

  void _init() {
    _ref.onDispose(() => _player.dispose());

    // أول تحميل
    _currentEdition = _ref.read(editionIdProvider);
    _currentChapter = _ref.read(chapterProvider);
    _reload();

    // لو تغيّر أيٌّ منهما، أعد التحميل
    _ref.listen<String>(editionIdProvider, (_, next) {
      _currentEdition = next;
      _reload();
    });
    _ref.listen<int>(chapterProvider, (_, next) {
      _currentChapter = next.clamp(1, 114);
      _reload();
    });
  }

  Future<void> _reload() async {
    this.state = const AsyncValue.loading();
    try {
      await _load(_currentEdition, _currentChapter);
      this.state = AsyncValue.data(
        _makeState(
          editionId: _currentEdition,
          chapter: _currentChapter,
          total: _tracks.length,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _load(String editionId, int chapter) async {
    final service = _ref.read(quranServiceProvider);
    final json = await service.getSurahAudio(editionId, chapter);
    final root = json['data'] ?? json;
    final List ayahs = (root['ayahs'] ?? root['verses'] ?? []) as List;

    _tracks
      ..clear()
      ..addAll(
        ayahs
            .map((a) => Map<String, dynamic>.from(a as Map))
            .map(
              (m) => (m['audio'] ?? m['audioUrl'] ?? m['url'] ?? '').toString(),
            )
            .where((u) => u.isNotEmpty)
            .map((u) => AudioSource.uri(Uri.parse(u))),
      );

    if (_tracks.isEmpty) {
      throw Exception('لا توجد روابط صوت في هذه النسخة ($editionId)');
    }

    // للإصدارات الحديثة من just_audio
    await _player.setAudioSources(_tracks);
  }

  PlaylistState _makeState({
    required String editionId,
    required int chapter,
    required int total,
  }) {
    return PlaylistState(
      editionId: editionId,
      chapter: chapter,
      total: total,
      durationStream: _player.durationStream,
      positionStream: _player.positionStream,
      bufferedStream: _player.bufferedPositionStream,
      indexStream: _player.currentIndexStream,
      playingStream: _player.playingStream,
      loopModeStream: _player.loopModeStream,
      volumeStream: _player.volumeStream,
    );
  }

  // تحكّم التشغيل
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> seekTo(Duration d) => _player.seek(d);

  // سرعة التشغيل
  Future<void> setSpeed(double value) async {
    final v = value.clamp(0.5, 2.0);
    await _player.setSpeed(v);

    state = AsyncValue.data(
      _makeState(
        editionId: _currentEdition,
        chapter: _currentChapter,
        total: _tracks.length,
      ),
    );
  }

  // تغييرات الإعدادات (ستُعيد التحميل تلقائياً عبر listen)
  Future<void> changeEdition(String ed) async {
    if (ed != _currentEdition) {
      _ref.read(editionIdProvider.notifier).state = ed;
    }
  }

  Future<void> changeChapter(int ch) async {
    final c = ch.clamp(1, 114);
    if (c != _currentChapter) {
      _ref.read(chapterProvider.notifier).state = c;
    }
  }

  // تكرار / كتم
  Future<void> toggleLoop() async {
    final cur = await _player.loopModeStream.first;
    await _player.setLoopMode(
      cur == LoopMode.off ? LoopMode.all : LoopMode.off,
    );
    state = AsyncValue.data(
      _makeState(
        editionId: _currentEdition,
        chapter: _currentChapter,
        total: _tracks.length,
      ),
    );
  }

  Future<void> toggleMute() async {
    final v = _player.volume;
    if (v > 0) {
      _lastVolume = v;
      await _player.setVolume(0);
    } else {
      await _player.setVolume(_lastVolume == 0 ? 1.0 : _lastVolume);
    }
    state = AsyncValue.data(
      _makeState(
        editionId: _currentEdition,
        chapter: _currentChapter,
        total: _tracks.length,
      ),
    );
  }
}
