import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';

/// Creates a native SQLite database connection for mobile and desktop.
///
/// Uses [NativeDatabase.createInBackground] so that DB operations
/// run on a separate isolate, avoiding UI jank during heavy queries.
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
