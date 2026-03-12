import 'package:audio_service/audio_service.dart';
import 'package:quranglow/core/service/audio/my_audio_handler.dart';

class MyAudioService {
  final MyAudioHandler _handler;

  MyAudioService(this._handler);

  Future<void> playUrl(String url, {String? title}) async {
    try {
      await _handler.playUri(Uri.parse(url), title: title);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pause() => _handler.pause();
  Future<void> stop() => _handler.stop();
  Stream<PlaybackState> get playbackState => _handler.playbackState;
  Stream<MediaItem?> get mediaItem => _handler.mediaItem;
}
