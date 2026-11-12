import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final Map<String, AudioPlayer> _players = {};
  double _volume = 0.65;

  Future<void> initialize() async {
    for (final name in [
      'tile',
      'place',
      'button',
      'invalid',
      'win',
      'shuffle',
    ]) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource('audio/$name.wav'));
      _players[name] = player;
    }
  }

  Future<void> play(String name, {required bool enabled}) async {
    if (!enabled) return;
    final player = _players[name];
    if (player == null) return;
    await player.stop();
    await player.setVolume(_volume);
    await player.resume();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0, 1);
    for (final player in _players.values) {
      await player.setVolume(_volume);
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
