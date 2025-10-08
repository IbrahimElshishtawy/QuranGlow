import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Stream<PlayerState> get playerState => _player.playerStateStream;
  void dispose() => _player.dispose();
}
