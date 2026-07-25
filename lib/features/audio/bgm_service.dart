// ═══════════════════════════════════════════════════════════════════════
// BgmService — Manages Background Music state
// Singleton ChangeNotifier backed by SettingsService for persistence.
// Audio files can be plugged in later via the onPlay/onPause callbacks.
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../../core/settings_service.dart';

enum BgmPlaybackState { stopped, playing, paused }

class BgmService extends ChangeNotifier {
  static final BgmService _instance = BgmService._();
  factory BgmService() => _instance;
  BgmService._();

  final SettingsService _settings = SettingsService();

  BgmPlaybackState _playbackState = BgmPlaybackState.stopped;

  BgmPlaybackState get playbackState => _playbackState;
  bool get enabled => _settings.bgmEnabled;
  bool get isPlaying => _playbackState == BgmPlaybackState.playing;

  /// Whether BGM is enabled AND currently playing (i.e. show pause icon)
  bool get showPause => enabled && isPlaying;

  /// Initialize — sync state from persisted setting.
  void init() {
    if (_settings.bgmEnabled) {
      _playbackState = BgmPlaybackState.stopped;
    } else {
      _playbackState = BgmPlaybackState.stopped;
    }
    notifyListeners();
  }

  /// Toggle BGM on/off in settings.
  void toggleEnabled() {
    _settings.bgmEnabled = !_settings.bgmEnabled;
    if (_settings.bgmEnabled) {
      _playbackState = BgmPlaybackState.playing;
      // Future: start actual audio playback here
    } else {
      _playbackState = BgmPlaybackState.stopped;
      // Future: stop actual audio playback here
    }
    notifyListeners();
  }

  /// Toggle play/pause (only when enabled).
  void togglePlayPause() {
    if (!_settings.bgmEnabled) return;
    if (_playbackState == BgmPlaybackState.playing) {
      _playbackState = BgmPlaybackState.paused;
      // Future: pause actual audio here
    } else {
      _playbackState = BgmPlaybackState.playing;
      // Future: resume actual audio here
    }
    notifyListeners();
  }

  /// Directly set enabled + start/stop playback.
  void setEnabled(bool value) {
    _settings.bgmEnabled = value;
    if (value) {
      _playbackState = BgmPlaybackState.playing;
      // Future: start audio playback
    } else {
      _playbackState = BgmPlaybackState.stopped;
      // Future: stop audio playback
    }
    notifyListeners();
  }
}
