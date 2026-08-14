import 'dart:async';

import 'package:flutter_soloud/flutter_soloud.dart';

class AudioController {

  SoLoud? _soloud;
  SoundHandle? _handle;
  AudioSource? _source;
  void Function()? _onPlayEndedCallback;
  Timer? _timer;
  bool _soundStarted = false;

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _callOnPlayEndedCallback();
    _timer?.cancel();
    _soloud?.deinit();
    _onPlayEndedCallback = null;
  }

  Future<void> playSound(String url) async {
    // Sound is already playing so ignore the request.
    if (isPlaying() && _soundStarted) {
      resumeSound();
      return;
    }
    try {
      _source ??= await _soloud!.loadUrl(url);
      _handle = await _soloud!.play(_source!);
      _soundStarted = true;
      _startPolling();
    } on SoLoudException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  void pauseSound() {
    if (!isPlaying()) {
      return;
    }
    try {
      _soloud?.setPause(_handle!, true);
    } on SoLoudNotInitializedException catch (e) {
      print(e);
    }
  }

  void resumeSound() {
    if (isPlaying() && !_soundStarted) {
      return;
    }
    try {
      _soloud?.setPause(_handle!, false);
    } on SoLoudNotInitializedException catch (e) {
      print(e);
    }
  }

  bool isPlaying() {
    int? countPlaying;
    countPlaying = _soloud?.getVoiceCount();
    return countPlaying != null && countPlaying > 0;
  }

  Future<void> stopSound() async {
    _onPlayEndedCallback = null;
    _timer?.cancel();
    if (_handle == null) return;
    try {
      _soloud?.stop(_handle!);
      await _soloud!.disposeSource(_source!);
      _handle = null;
      _source = null;
    } on SoLoudException catch (e) {
      print(e);
    }
  }

  Future<void> startMusic() async {
    print('Not implemented yet.');
  }

  void fadeOutMusic() {
    print('Not implemented yet.');
  }

  void applyFilter() {
    // TODO
  }

  void removeFilter() {
    // TODO
  }

  void onPlayEnded(void Function() cb) {
    _onPlayEndedCallback = cb;
  }

  void _startPolling() {
    final duration = Duration(milliseconds: 500);
    _timer = Timer.periodic(duration, (timer) {
      if (_soundStarted && !isPlaying()) {
        _callOnPlayEndedCallback();
        _soundStarted = false;
      }
    });
  }
  void _callOnPlayEndedCallback() {
    if (_onPlayEndedCallback != null) {
      _onPlayEndedCallback!();
    }
  }
}
