import 'dart:async';
import 'package:flutter/foundation.dart';

import '../domain/models/enums.dart';
import '../domain/models/song.dart';
import '../domain/repositories/song_repository.dart';
import '../domain/services/music_scanner_service.dart';
import '../domain/services/permission_service.dart';

enum ScanStatus {
  idle,
  checkingPermission,
  permissionDenied,
  permissionPermanentlyDenied,
  scanning,
  indexing,
  completed,
  error,
}

/// Provider managing library data, scanning, permissions, and indexing.
class LibraryProvider extends ChangeNotifier {
  final SongRepository songRepository;
  final MusicScannerService scannerService;
  final PermissionService permissionService;

  ScanStatus _status = ScanStatus.idle;
  int _scannedCount = 0;
  int _totalToScan = 0;
  String? _errorMessage;

  List<Song> _songs = [];
  SortField _sortField = SortField.title;
  SortOrder _sortOrder = SortOrder.ascending;

  StreamSubscription<List<Song>>? _songsSubscription;

  LibraryProvider({
    required this.songRepository,
    required this.scannerService,
    required this.permissionService,
  }) {
    _init();
  }

  // Getters
  ScanStatus get status => _status;
  int get scannedCount => _scannedCount;
  int get totalToScan => _totalToScan;
  double get scanProgress =>
      _totalToScan > 0 ? (_scannedCount / _totalToScan).clamp(0.0, 1.0) : 0.0;
  String? get errorMessage => _errorMessage;
  List<Song> get songs => _songs;
  int get songCount => _songs.length;
  SortField get sortField => _sortField;
  SortOrder get sortOrder => _sortOrder;

  void _init() {
    _loadSongs();
    _songsSubscription = songRepository.watchAllSongs().listen((updatedSongs) {
      _applySort(updatedSongs);
    });
  }

  @override
  void dispose() {
    _songsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    final list = await songRepository.getAllSongs(
      sortBy: _sortField,
      order: _sortOrder,
    );
    _songs = list;
    notifyListeners();
  }

  void setSorting(SortField field, SortOrder order) {
    _sortField = field;
    _sortOrder = order;
    _applySort(_songs);
  }

  void _applySort(List<Song> input) {
    final list = List<Song>.from(input);
    final isAsc = _sortOrder == SortOrder.ascending;

    list.sort((a, b) {
      final cmp = switch (_sortField) {
        SortField.title => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()),
        SortField.artist => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        SortField.album => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
        SortField.dateAdded => a.dateAdded.compareTo(b.dateAdded),
        SortField.duration => a.durationMs.compareTo(b.durationMs),
        SortField.fileName => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()),
        SortField.custom => a.id.compareTo(b.id),
      };
      return isAsc ? cmp : -cmp;
    });

    _songs = list;
    notifyListeners();
  }

  /// Initiates or rescans the music library with permission checks.
  Future<void> scanLibrary({bool forceFullRescan = false}) async {
    _status = ScanStatus.checkingPermission;
    _errorMessage = null;
    notifyListeners();

    // 1. Check or request permission
    var perm = await permissionService.checkAudioPermission();
    if (perm != AppPermissionStatus.granted) {
      perm = await permissionService.requestAudioPermission();
    }

    if (perm == AppPermissionStatus.permanentlyDenied) {
      _status = ScanStatus.permissionPermanentlyDenied;
      notifyListeners();
      return;
    } else if (perm != AppPermissionStatus.granted) {
      _status = ScanStatus.permissionDenied;
      notifyListeners();
      return;
    }

    // 2. Start scanning
    _status = ScanStatus.scanning;
    _scannedCount = 0;
    _totalToScan = 0;
    notifyListeners();

    try {
      final discoveredFiles = await scannerService.scanMusic(
        onProgress: (current, total) {
          _scannedCount = current;
          _totalToScan = total;
          notifyListeners();
        },
      );

      _status = ScanStatus.indexing;
      notifyListeners();

      // 3. Incremental indexing
      final indexedPaths = await songRepository.getAllIndexedPaths();
      final discoveredPaths = discoveredFiles.map((f) => f.filePath).toSet();

      // Songs to insert
      final toInsert = discoveredFiles
          .where((f) => forceFullRescan || !indexedPaths.contains(f.filePath))
          .map(
            (f) => Song(
              id: 0,
              filePath: f.filePath,
              fileName: f.fileName,
              title: f.title,
              artist: f.artist,
              album: f.album,
              albumArtist: f.albumArtist,
              genre: f.genre,
              trackNumber: f.trackNumber,
              durationMs: f.durationMs,
              fileSize: f.fileSize,
              format: f.format,
              bitrate: f.bitrate,
              sampleRate: f.sampleRate,
              hasArtwork: f.hasArtwork,
              hasLyrics: f.hasLyrics,
              dateAdded: DateTime.fromMillisecondsSinceEpoch(f.dateAdded),
              dateModified: DateTime.fromMillisecondsSinceEpoch(f.dateModified),
            ),
          )
          .toList();

      if (toInsert.isNotEmpty) {
        await songRepository.insertSongs(toInsert);
      }

      // Remove deleted files from library if not forcing rescan
      if (!forceFullRescan) {
        final removedPaths = indexedPaths.difference(discoveredPaths);
        for (final removedPath in removedPaths) {
          await songRepository.deleteSongByPath(removedPath);
        }
      }

      _status = ScanStatus.completed;
      await _loadSongs();
    } catch (e, st) {
      debugPrint('Error scanning music: $e\n$st');
      _status = ScanStatus.error;
      _errorMessage = 'Scan failed: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    await permissionService.openAppSettings();
  }
}
