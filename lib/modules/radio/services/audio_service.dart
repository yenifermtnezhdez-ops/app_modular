
import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/station_model.dart';

class RadioAudioHandler extends audio.BaseAudioHandler
    with audio.QueueHandler, audio.SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<AudioInterruptionEvent>?
      _interruptionSubscription;

  StreamSubscription<PlaybackEvent>? _playbackSubscription;

  bool _resumeAfterInterruption = false;
  bool _pauseInterruptionActive = false;

  double? _volumeBeforeDuck;

  RadioAudioHandler() {
    _playbackSubscription = _player.playbackEventStream.listen(
      (event) {
        playbackState.add(_transformEvent(event));
      },
      onError: (Object error, StackTrace stackTrace) {
        _setPlaybackError(error);
      },
    );

    unawaited(_initializeInterruptionHandling());
  }

  AudioPlayer get player => _player;

  // Configuración de interrupciones de audio.
  Future<void> _initializeInterruptionHandling() async {
    try {
      final session = await AudioSession.instance;

      await session.configure(
        const AudioSessionConfiguration.music(),
      );

      _interruptionSubscription =
          session.interruptionEventStream.listen(
        (event) {
          unawaited(_handleInterruption(event));
        },
        onError: (Object error) {
          debugPrint('Error en interrupción de audio: $error');
        },
      );
    } catch (e) {
      debugPrint(
        'No se pudo configurar el manejo de interrupciones: $e',
      );
    }
  }

  // Manejo de llamadas, notificaciones y otras interrupciones.
  Future<void> _handleInterruption(
    AudioInterruptionEvent event,
  ) async {
    try {
      if (event.begin) {
        if (event.type == AudioInterruptionType.duck) {
          _volumeBeforeDuck ??= _player.volume;

          await _player.setVolume(
            _volumeBeforeDuck! * 0.2,
          );

          return;
        }

        if (!_pauseInterruptionActive) {
          _pauseInterruptionActive = true;
          _resumeAfterInterruption = _player.playing;
        }

        if (_player.playing) {
          await _player.pause();
        }
      } else {
        if (event.type == AudioInterruptionType.duck) {
          await _restoreVolume();
          return;
        }

        _pauseInterruptionActive = false;

        if (_resumeAfterInterruption) {
          _resumeAfterInterruption = false;
          await _player.play();
        }
      }
    } catch (e) {
      debugPrint('Error al manejar interrupción: $e');
    }
  }

  // Restaurar el volumen anterior.
  Future<void> _restoreVolume() async {
    if (_volumeBeforeDuck != null) {
      final previousVolume = _volumeBeforeDuck!;

      _volumeBeforeDuck = null;

      await _player.setVolume(previousVolume);
    }
  }

  // Mostrar y registrar errores de reproducción.
  void _setPlaybackError(Object error) {
    debugPrint('ERROR DE REPRODUCCIÓN: $error');

    playbackState.add(
      audio.PlaybackState(
        controls: const [
          audio.MediaControl.play,
          audio.MediaControl.stop,
        ],
        processingState: audio.AudioProcessingState.error,
        playing: false,
        errorMessage: error.toString(),
      ),
    );
  }

  // Seleccionar y reproducir una estación.
  Future<void> playStation(StationModel station) async {
    try {
      debugPrint('Seleccionando estación: ${station.name}');
      debugPrint('URL del streaming: ${station.streamUrl}');

      _resumeAfterInterruption = false;
      _pauseInterruptionActive = false;

      await _restoreVolume();

      // Detener cualquier reproducción anterior.
      await _player.stop();

      final streamUri = Uri.tryParse(station.streamUrl);

      if (streamUri == null ||
          !streamUri.hasAuthority ||
          streamUri.host.isEmpty ||
          (streamUri.scheme != 'https' &&
              streamUri.scheme != 'http')) {
        throw FormatException(
          'La URL de streaming no es válida: ${station.streamUrl}',
        );
      }

      final mediaItem = audio.MediaItem(
        id: station.id,
        album: station.slogan,
        title: station.name,
        artist: station.acronym,
        artUri: Uri.tryParse(station.imageUrl),
        extras: {
          'streamUrl': station.streamUrl,
          'stationId': station.id,
        },
      );

      this.mediaItem.add(mediaItem);
      queue.add([mediaItem]);

      debugPrint('Cargando transmisión...');

      // Cargar la dirección del streaming.
      await _player.setAudioSource(
        AudioSource.uri(
          streamUri,
          tag: mediaItem,
        ),
      );

      debugPrint('Streaming cargado correctamente.');

      // Iniciar reproducción sin bloquear la interfaz.
      unawaited(_startPlayback(station.name));
    } catch (e, stackTrace) {
      debugPrint('Error al cargar ${station.name}: $e');
      debugPrintStack(stackTrace: stackTrace);

      _setPlaybackError(e);

      rethrow;
    }
  }

  // Iniciar la reproducción y capturar errores posteriores.
  Future<void> _startPlayback(String stationName) async {
    try {
      debugPrint('Iniciando reproducción: $stationName');

      await _player.play();

      debugPrint('Reproducción finalizada o detenida: $stationName');
    } catch (e, stackTrace) {
      debugPrint('Error reproduciendo $stationName: $e');
      debugPrintStack(stackTrace: stackTrace);

      _setPlaybackError(e);
    }
  }

  @override
  Future<void> play() async {
    _resumeAfterInterruption = false;

    try {
      await _player.play();
    } catch (e) {
      _setPlaybackError(e);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    _resumeAfterInterruption = false;

    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _resumeAfterInterruption = false;
    _pauseInterruptionActive = false;

    await _restoreVolume();
    await _player.stop();

    mediaItem.add(null);
    queue.add([]);

    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Actualizar el estado de reproducción y los controles multimedia.
  audio.PlaybackState _transformEvent(PlaybackEvent event) {
    return audio.PlaybackState(
      controls: [
        if (_player.playing)
          audio.MediaControl.pause
        else
          audio.MediaControl.play,
        audio.MediaControl.stop,
      ],
      systemActions: const {
        audio.MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: {
        ProcessingState.idle:
            audio.AudioProcessingState.idle,
        ProcessingState.loading:
            audio.AudioProcessingState.loading,
        ProcessingState.buffering:
            audio.AudioProcessingState.buffering,
        ProcessingState.ready:
            audio.AudioProcessingState.ready,
        ProcessingState.completed:
            audio.AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Liberar recursos cuando se cierre el servicio.
  Future<void> disposePlayer() async {
    await _interruptionSubscription?.cancel();
    await _playbackSubscription?.cancel();
    await _player.dispose();
  }
}
