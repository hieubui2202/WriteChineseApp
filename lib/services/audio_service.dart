import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (error) {
      // ignore: avoid_print
      print('Audio playback error: $error');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
