
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/station_model.dart';
import '../../services/audio_service.dart' as radio;

class AudioProvider extends ChangeNotifier {
  final radio.RadioAudioHandler _audioService;

  StationModel? _currentStation;

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _disposed = false;

  String? _errorMessage;

  int _requestId = 0;

  Future<void> _operationQueue = Future<void>.value();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;

  AudioProvider({
    required radio.RadioAudioHandler audioHandler,
  }) : _audioService = audioHandler {
    _playerStateSubscription =
        _audioService.player.playerStateStream.listen(
      (state) {
        if (_disposed) return;

        _isPlaying = state.playing;

        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }

        notifyListeners();
      },
      onError: (Object error) {
        if (_disposed) return;

        _errorMessage = 'Error de reproducción: $error';
        _isLoading = false;
        _isPlaying = false;

        notifyListeners();
      },
    );

    _playbackEventSubscription =
        _audioService.player.playbackEventStream.listen(
      (_) {},
      onError: (Object error) {
        if (_disposed) return;

        _errorMessage = 'No se pudo reproducir el audio: $error';
        _isLoading = false;
        _isPlaying = false;

        notifyListeners();
      },
    );
  }

  StationModel? get currentStation => _currentStation;

  bool get isLoading => _isLoading;

  bool get isPlaying => _isPlaying;

  String? get errorMessage => _errorMessage;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.isNotEmpty;

  bool get isPaused =>
      _currentStation != null &&
      !_isLoading &&
      !_isPlaying &&
      !hasError;

  Future<void> playStation(StationModel station) async {
    final int requestId = ++_requestId;

    _currentStation = station;
    _isLoading = true;
    _isPlaying = false;
    _errorMessage = null;

    notifyListeners();

    final operation = _operationQueue.then((_) async {
      if (_disposed || requestId != _requestId) return;

      try {
        await _audioService.playStation(station);

        if (_disposed || requestId != _requestId) return;
      } catch (e) {
        if (_disposed || requestId != _requestId) return;

        _errorMessage = 'No se pudo reproducir la estación: $e';
        _isPlaying = false;

        debugPrint('ERROR DEL AUDIO PROVIDER: $e');
      } finally {
        if (!_disposed && requestId == _requestId) {
          _isLoading = false;
          notifyListeners();
        }
      }
    });

    _operationQueue = operation.catchError((Object error) {
      debugPrint('ERROR EN LA COLA DE AUDIO: $error');
    });

    await operation;
  }

  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      if (_disposed) return;

      _errorMessage = 'No se pudo pausar el audio: $e';
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> resume() async {
    if (_currentStation == null) return;

    try {
      _errorMessage = null;
      notifyListeners();

      await _audioService.play();
    } catch (e) {
      if (_disposed) return;

      _errorMessage = 'No se pudo reanudar el audio: $e';
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    ++_requestId;

    _isLoading = false;

    try {
      await _operationQueue;
      await _audioService.stop();

      if (_disposed) return;

      _currentStation = null;
      _isPlaying = false;
      _errorMessage = null;
    } catch (e) {
      if (_disposed) return;

      _errorMessage = 'No se pudo detener el audio: $e';
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    _playerStateSubscription?.cancel();
    _playbackEventSubscription?.cancel();

    super.dispose();
  }
}
