import 'package:drift/drift.dart';

/// Logs files that failed during library scanning.
///
/// Allows the scan to continue past errors while preserving
/// a report for the user.
@DataClassName('ScanErrorEntity')
class ScanErrors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  TextColumn get error => text()();
  DateTimeColumn get scannedAt => dateTime()();
}
