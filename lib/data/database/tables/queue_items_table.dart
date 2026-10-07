import 'package:drift/drift.dart';

import 'songs_table.dart';

/// Persisted queue for playback state restoration across app restarts.
///
/// [isCurrent] marks the song that was actively playing when the app closed.
@DataClassName('QueueItemEntity')
class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
}
