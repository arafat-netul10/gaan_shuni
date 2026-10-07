import 'package:drift/drift.dart';

/// Drift table for the songs index — the core of the music library.
///
/// Uses @DataClassName to avoid naming conflict with the domain Song model.
@DataClassName('SongEntity')
class Songs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get fileName => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown'))();
  TextColumn get album => text().withDefault(const Constant('Unknown'))();
  TextColumn get albumArtist => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get durationMs => integer()();
  IntColumn get fileSize => integer()();
  TextColumn get format => text()();
  IntColumn get bitrate => integer().nullable()();
  IntColumn get sampleRate => integer().nullable()();
  BoolColumn get hasArtwork => boolean().withDefault(const Constant(false))();
  TextColumn get artworkPath => text().nullable()();
  BoolColumn get hasLyrics => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get dateModified => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
}
