import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/models/enums.dart';

/// AudioHandler implementation bridging `audio_service` and `just_audio`.
///
/// Handles audio focus via `audio_session`, lock screen and notification media controls,
/// Bluetooth media buttons, and headphone unplugging events.
class GaanShuniAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<MediaItem> _originalQueue = [];
  RepeatMode _repeatMode = RepeatMode.off;
  bool _shuffleMode = false;

  GaanShuniAudioHandler() {
    _initAudioSession();
    _listenToPlaybackEvents();
  }

  AudioPlayer get player => _player;
  RepeatMode get repeatMode => _repeatMode;
  bool get shuffleMode => _shuffleMode;

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Pause on headphone unplug
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });

    // Handle audio focus interruptions (e.g. phone call)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
  }

  void _listenToPlaybackEvents() {
    // Broadcast playback state changes to system
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.setShuffleMode,
            MediaAction.setRepeatMode,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });

    // Handle track completion
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });

    // Listen to current position and duration
    _player.durationStream.listen((dur) {
      final currentItem = mediaItem.value;
      if (currentItem != null && dur != null) {
        mediaItem.add(currentItem.copyWith(duration: dur));
      }
    });
  }

  void _onTrackCompleted() {
    if (_repeatMode == RepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else {
      final hasNext = _hasNextTrack();
      if (hasNext) {
        skipToNext();
      } else if (_repeatMode == RepeatMode.all) {
        skipToQueueItem(0);
      } else {
        stop();
      }
    }
  }

  bool _hasNextTrack() {
    final currentList = queue.value;
    final current = mediaItem.value;
    if (current == null || currentList.isEmpty) return false;
    final currentIndex = currentList.indexWhere((item) => item.id == current.id);
    return currentIndex != -1 && currentIndex < currentList.length - 1;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final currentList = queue.value;
    final current = mediaItem.value;
    if (currentList.isEmpty || current == null) return;

    final index = currentList.indexWhere((item) => item.id == current.id);
    if (index != -1 && index < currentList.length - 1) {
      await skipToQueueItem(index + 1);
    } else if (_repeatMode == RepeatMode.all && currentList.isNotEmpty) {
      await skipToQueueItem(0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If playback is beyond 3 seconds, restart current track
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    final currentList = queue.value;
    final current = mediaItem.value;
    if (currentList.isEmpty || current == null) return;

    final index = currentList.indexWhere((item) => item.id == current.id);
    if (index > 0) {
      await skipToQueueItem(index - 1);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final currentList = queue.value;
    if (index < 0 || index >= currentList.length) return;

    final targetItem = currentList[index];
    mediaItem.add(targetItem);

    try {
      if (targetItem.extras != null && targetItem.extras!['filePath'] != null) {
        final filePath = targetItem.extras!['filePath'] as String;
        await _player.setFilePath(filePath);
        await _player.play();
      }
    } catch (e) {
      debugPrint('Error playing audio file: $e');
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    _originalQueue.clear();
    _originalQueue.addAll(queue);
    if (_shuffleMode) {
      _applyShuffle();
    } else {
      this.queue.add(queue);
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _originalQueue.add(mediaItem);
    final current = List<MediaItem>.from(queue.value);
    current.add(mediaItem);
    queue.add(current);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    final current = List<MediaItem>.from(queue.value);
    if (index >= 0 && index < current.length) {
      final removed = current.removeAt(index);
      _originalQueue.removeWhere((item) => item.id == removed.id);
      queue.add(current);
    }
  }

  void setDomainRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
  }

  void setShuffle(bool enabled) {
    if (_shuffleMode == enabled) return;
    _shuffleMode = enabled;
    if (_shuffleMode) {
      _applyShuffle();
    } else {
      queue.add(List.from(_originalQueue));
    }
  }

  void _applyShuffle() {
    final current = mediaItem.value;
    final list = List<MediaItem>.from(_originalQueue);
    if (current != null) {
      list.removeWhere((item) => item.id == current.id);
      list.shuffle();
      list.insert(0, current);
    } else {
      list.shuffle();
    }
    queue.add(list);
  }
}
