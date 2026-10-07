import 'package:drift/drift.dart';

/// Drift table for user-created playlists.
@DataClassName('PlaylistEntity')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
