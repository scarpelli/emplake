import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/settings_controller.dart';

enum Sfx {
  tap('audio/tap.wav'),
  link('audio/link.wav'),
  success('audio/success.wav'),
  error('audio/error.wav'),
  timeUp('audio/timeup.wav');

  const Sfx(this.asset);
  final String asset;
}

class SoundService {
  SoundService(this._ref) {
    _ref.listen<AppSettings>(settingsProvider, (prev, next) {
      if (prev?.music != next.music) next.music ? _startMusic() : _stopMusic();
    });
  }

  final Ref _ref;
  final _sfxPlayers = <Sfx, AudioPlayer>{};
  AudioPlayer? _music;

  bool get _sfxOn => _ref.read(settingsProvider).sfx;

  Future<void> play(Sfx sfx) async {
    if (!_sfxOn) return;
    try {
      final p = _sfxPlayers.putIfAbsent(sfx, () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency));
      await p.stop();
      await p.play(AssetSource(sfx.asset), volume: 0.7);
    } catch (_) {
    }
  }

  bool _gestureSeen = false;

  void onFirstGesture() {
    if (_gestureSeen) return;
    _gestureSeen = true;
    resumeMusicIfEnabled();
  }

  void resumeMusicIfEnabled() {
    if (_ref.read(settingsProvider).music) _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      _music ??= AudioPlayer();
      await _music!.setReleaseMode(ReleaseMode.loop);
      await _music!.play(AssetSource('audio/music.wav'), volume: 0.35);
    } catch (_) {}
  }

  Future<void> _stopMusic() async {
    try {
      await _music?.stop();
    } catch (_) {}
  }

  void dispose() {
    for (final p in _sfxPlayers.values) {
      p.dispose();
    }
    _music?.dispose();
  }
}

final soundProvider = Provider<SoundService>((ref) {
  final s = SoundService(ref);
  ref.onDispose(s.dispose);
  return s;
});
