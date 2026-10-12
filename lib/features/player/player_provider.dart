import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/song.dart';
import '../../domain/repositories/playback_state_repository.dart';
import '../../domain/repositories/song_repository.dart';
import 'audio_player_handler.dart';

/// App-wide provider managing playback state, queue, and playback controls.
class PlayerProvider extends ChangeNotifier {
  final GaanShuniAudioHandler audioHandler;
  final SongRepository songRepository;
  final PlaybackStateRepository playbackStateRepository;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _isShuffle = false;

  final Map<String, Song> _songCache = {};

  StreamSubscription? _playbackStateSub;
  StreamSubscription? _mediaItemSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  PlayerProvider({
    required this.audioHandler,
    required this.songRepository,
    required this.playbackStateRepository,
  }) {
    _init();
  }

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffle => _isShuffle;

  void _init() {
    _playbackStateSub = audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _mediaItemSub = audioHandler.mediaItem.listen((item) async {
      if (item != null) {
        final id = int.tryParse(item.id);
        if (id != null) {
          _currentSong = _songCache[item.id] ?? await songRepository.getSongById(id);
          if (_currentSong != null) {
            _songCache[item.id] = _currentSong!;
            await songRepository.recordPlay(_currentSong!.id);
            await playbackStateRepository.saveLastSongId(_currentSong!.id);
          }
        }
      }
      notifyListeners();
    });

    _positionSub = audioHandler.player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub = audioHandler.player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _restoreSavedState();
  }

  @override
  void dispose() {
    _playbackStateSub?.cancel();
    _mediaItemSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }

  List<QueueItem> _toQueueItems(List<Song> songs, int currentSongId) {
    return [
      for (int i = 0; i < songs.length; i++)
        QueueItem(
          songId: songs[i].id,
          song: songs[i],
          sortOrder: i,
          isCurrent: songs[i].id == currentSongId,
        ),
    ];
  }

  Future<void> _restoreSavedState() async {
    try {
      _repeatMode = await playbackStateRepository.getRepeatMode();
      _isShuffle = await playbackStateRepository.getShuffleEnabled();
      audioHandler.setDomainRepeatMode(_repeatMode);
      audioHandler.setShuffle(_isShuffle);

      final savedQueueItems = await playbackStateRepository.getQueue();
      if (savedQueueItems.isNotEmpty) {
        final List<Song> restoredSongs = [];
        for (final item in savedQueueItems) {
          if (item.song != null) {
            restoredSongs.add(item.song!);
            _songCache[item.song!.id.toString()] = item.song!;
          }
        }
        if (restoredSongs.isNotEmpty) {
          _queue = restoredSongs;
          final mediaItems = restoredSongs.map(_toMediaItem).toList();
          await audioHandler.updateQueue(mediaItems);

          final currentItem = savedQueueItems.firstWhere(
            (item) => item.isCurrent,
            orElse: () => savedQueueItems.first,
          );
          if (currentItem.song != null) {
            _currentSong = currentItem.song;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error restoring playback state: $e');
    }
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.id.toString(),
      title: song.displayTitle,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.durationMs),
      extras: {'filePath': song.filePath},
    );
  }

  /// Plays a song within an optional playlist/library context.
  Future<void> playSong(Song song, {List<Song>? contextQueue}) async {
    final list = contextQueue != null && contextQueue.isNotEmpty
        ? List<Song>.from(contextQueue)
        : [song];

    _queue = list;
    for (final s in list) {
      _songCache[s.id.toString()] = s;
    }

    final mediaItems = list.map(_toMediaItem).toList();
    await audioHandler.updateQueue(mediaItems);

    final targetIndex = list.indexWhere((s) => s.id == song.id);
    await audioHandler.skipToQueueItem(targetIndex >= 0 ? targetIndex : 0);

    // Persist queue
    await playbackStateRepository.saveQueue(_toQueueItems(list, song.id));
  }

  Future<void> play() => audioHandler.play();

  Future<void> pause() => audioHandler.pause();

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) => audioHandler.seek(position);

  Future<void> skipToNext() => audioHandler.skipToNext();

  Future<void> skipToPrevious() => audioHandler.skipToPrevious();

  Future<void> cycleRepeatMode() async {
    _repeatMode = _repeatMode.next;
    audioHandler.setDomainRepeatMode(_repeatMode);
    await playbackStateRepository.saveRepeatMode(_repeatMode);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffle = !_isShuffle;
    audioHandler.setShuffle(_isShuffle);
    await playbackStateRepository.saveShuffleEnabled(_isShuffle);
    notifyListeners();
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      await audioHandler.removeQueueItemAt(index);
      if (_currentSong != null) {
        await playbackStateRepository.saveQueue(
          _toQueueItems(_queue, _currentSong!.id),
        );
      }
      notifyListeners();
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);

    final mediaItems = _queue.map(_toMediaItem).toList();
    await audioHandler.updateQueue(mediaItems);

    if (_currentSong != null) {
      await playbackStateRepository.saveQueue(
        _toQueueItems(_queue, _currentSong!.id),
      );
    }
    notifyListeners();
  }

  Future<void> toggleCurrentSongFavorite() async {
    if (_currentSong != null) {
      await songRepository.toggleFavorite(_currentSong!.id);
      _currentSong = await songRepository.getSongById(_currentSong!.id);
      if (_currentSong != null) {
        _songCache[_currentSong!.id.toString()] = _currentSong!;
        final qIndex = _queue.indexWhere((s) => s.id == _currentSong!.id);
        if (qIndex >= 0) {
          _queue[qIndex] = _currentSong!;
        }
      }
      notifyListeners();
    }
  }
}
