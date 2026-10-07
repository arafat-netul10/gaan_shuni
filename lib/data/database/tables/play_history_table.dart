import 'package:drift/drift.dart';

import 'songs_table.dart';

/// Tracks playback history — a song enters this table when playback begins.
@DataClassName('PlayHistoryEntity')
class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId => integer().references(Songs, #id)();
  DateTimeColumn get playedAt => dateTime()();
}
