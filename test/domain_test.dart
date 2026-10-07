import 'package:flutter_test/flutter_test.dart';
import 'package:gaan_shuni/core/theme/app_colors.dart';
import 'package:gaan_shuni/domain/models/enums.dart';
import 'package:gaan_shuni/domain/models/playlist.dart';
import 'package:gaan_shuni/domain/models/song.dart';

void main() {
  group('RepeatMode', () {
    test('cycles correctly: off -> all -> one -> off', () {
      expect(RepeatMode.off.next, RepeatMode.all);
      expect(RepeatMode.all.next, RepeatMode.one);
      expect(RepeatMode.one.next, RepeatMode.off);
    });
  });

  group('Song Model', () {
    final now = DateTime.now();
    final song = Song(
      id: 1,
      filePath: r'C:\Music\Rabindra Sangeet\Ami Chini Go Chini.mp3',
      fileName: 'Ami Chini Go Chini.mp3',
      title: 'Ami Chini Go Chini',
      artist: 'Kishore Kumar',
      album: 'Geetanjali',
      durationMs: 180000,
      fileSize: 4500000,
      format: 'mp3',
      dateAdded: now,
      dateModified: now,
    );

    test('displayTitle falls back to fileName when title is empty', () {
      expect(song.displayTitle, 'Ami Chini Go Chini');
      final fallbackSong = song.copyWith(title: '');
      expect(fallbackSong.displayTitle, 'Ami Chini Go Chini.mp3');
    });

    test('folderPath extracts directory path correctly', () {
      expect(song.folderPath, r'C:\Music\Rabindra Sangeet');

      final unixSong = song.copyWith(filePath: '/storage/emulated/0/Music/track.mp3');
      expect(unixSong.folderPath, '/storage/emulated/0/Music');
    });

    test('copyWith updates properties properly', () {
      final updated = song.copyWith(isFavorite: true, playCount: 5);
      expect(updated.isFavorite, true);
      expect(updated.playCount, 5);
      expect(updated.id, song.id);
      expect(updated.title, song.title);
    });
  });

  group('Playlist Model', () {
    test('instantiates and equality holds by ID', () {
      final now = DateTime.now();
      final p1 = Playlist(id: 1, name: 'Evening Chill', createdAt: now, updatedAt: now);
      final p2 = Playlist(id: 1, name: 'Different Name', createdAt: now, updatedAt: now);
      final p3 = Playlist(id: 2, name: 'Evening Chill', createdAt: now, updatedAt: now);

      expect(p1 == p2, isTrue);
      expect(p1 == p3, isFalse);
    });
  });

  group('AppColors', () {
    test('gradientForHash returns valid color pairs deterministically', () {
      final g1 = AppColors.gradientForHash(42);
      final g2 = AppColors.gradientForHash(42);
      expect(g1, equals(g2));
      expect(g1.length, 2);

      final gNegative = AppColors.gradientForHash(-15);
      expect(gNegative.length, 2);
    });
  });
}
