import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';
import '../../domain/services/music_scanner_service.dart';

/// Implementation of [MusicScannerService].
///
/// On Android and iOS, queries the device media store via [OnAudioQuery].
/// On Windows and desktop platforms, searches common music directories and builds track info.
class DeviceMusicScannerService implements MusicScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Future<List<DiscoveredAudioFile>> scanMusic({
    void Function(int current, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      return [];
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return _scanMobile(onProgress);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _scanDesktop(onProgress);
    }

    return [];
  }

  Future<List<DiscoveredAudioFile>> _scanMobile(
    void Function(int current, int total)? onProgress,
  ) async {
    try {
      final hasPermission = await _audioQuery.checkAndRequest();
      if (!hasPermission) {
        debugPrint('OnAudioQuery permission not granted');
        return [];
      }

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final List<DiscoveredAudioFile> result = [];
      final total = songs.length;

      for (int i = 0; i < songs.length; i++) {
        try {
          final s = songs[i];
          final filePath = s.data.trim();
          if (filePath.isEmpty) continue;

          final displayName = s.displayName.trim().isNotEmpty
              ? s.displayName.trim()
              : p.basename(filePath);
          final ext = p.extension(displayName).toLowerCase().replaceAll('.', '');
          final format = ext.isNotEmpty ? ext : 'mp3';

          // Check if format is supported
          if (AppConstants.supportedFormats.contains(format) || format == 'flac') {
            final rawTitle = s.title.trim();
            final title = rawTitle.isNotEmpty ? rawTitle : displayName;
            final artist = (s.artist != null &&
                    s.artist != '<unknown>' &&
                    s.artist!.trim().isNotEmpty)
                ? s.artist!.trim()
                : 'Unknown Artist';
            final album = (s.album != null &&
                    s.album != '<unknown>' &&
                    s.album!.trim().isNotEmpty)
                ? s.album!.trim()
                : 'Unknown Album';

            result.add(
              DiscoveredAudioFile(
                filePath: filePath,
                fileName: displayName,
                title: title,
                artist: artist,
                album: album,
                genre: s.genre,
                trackNumber: s.track,
                durationMs: s.duration ?? 0,
                fileSize: s.size,
                format: format,
                hasArtwork: s.id > 0,
                dateAdded: s.dateAdded != null
                    ? s.dateAdded! * 1000
                    : DateTime.now().millisecondsSinceEpoch,
                dateModified: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }
        } catch (itemError) {
          debugPrint('Error parsing audio item $i: $itemError');
        }

        if (onProgress != null && (i % 20 == 0 || i == total - 1)) {
          onProgress(i + 1, total);
        }
      }

      return result;
    } catch (e) {
      debugPrint('Mobile scan error: $e');
      return [];
    }
  }

  Future<List<DiscoveredAudioFile>> _scanDesktop(
    void Function(int current, int total)? onProgress,
  ) async {
    final List<DiscoveredAudioFile> result = [];
    final List<Directory> searchDirs = [];

    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final musicDir = Directory(p.join(userProfile, 'Music'));
        if (musicDir.existsSync()) searchDirs.add(musicDir);
        final downloadsDir = Directory(p.join(userProfile, 'Downloads'));
        if (downloadsDir.existsSync()) searchDirs.add(downloadsDir);
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final musicDir = Directory(p.join(home, 'Music'));
        if (musicDir.existsSync()) searchDirs.add(musicDir);
      }
    }

    // Collect all candidate audio files
    final List<File> audioFiles = [];
    for (final dir in searchDirs) {
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
            if (AppConstants.supportedFormats.contains(ext) || ext == 'flac') {
              audioFiles.add(entity);
            }
          }
        }
      } catch (e) {
        debugPrint('Directory listing error: $e');
      }
    }

    final total = audioFiles.length;
    for (int i = 0; i < audioFiles.length; i++) {
      final file = audioFiles[i];
      try {
        final stat = await file.stat();
        final name = p.basename(file.path);
        final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
        final titleWithoutExt = p.basenameWithoutExtension(file.path);

        result.add(
          DiscoveredAudioFile(
            filePath: file.path,
            fileName: name,
            title: titleWithoutExt,
            artist: 'Unknown Artist',
            album: 'Unknown Album',
            durationMs: 0,
            fileSize: stat.size,
            format: ext,
            dateAdded: stat.changed.millisecondsSinceEpoch,
            dateModified: stat.modified.millisecondsSinceEpoch,
          ),
        );
      } catch (_) {
        // Skip unreadable files
      }

      if (onProgress != null && (i % 20 == 0 || i == total - 1)) {
        onProgress(i + 1, total);
      }
    }

    return result;
  }
}
