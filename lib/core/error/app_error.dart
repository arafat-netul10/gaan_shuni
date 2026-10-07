/// Base class for application errors.
///
/// Uses sealed class for exhaustive pattern matching.
/// Error messages are user-friendly per the product spec —
/// technical details are kept separate for logging.
sealed class AppError {
  final String message;
  final String? technicalDetail;

  const AppError(this.message, {this.technicalDetail});

  @override
  String toString() => technicalDetail != null
      ? '$message ($technicalDetail)'
      : message;
}

class PlaybackError extends AppError {
  const PlaybackError({String? detail})
      : super("Couldn't play this file.", technicalDetail: detail);
}

class FileRenameError extends AppError {
  const FileRenameError({String? detail})
      : super("Couldn't rename the file.", technicalDetail: detail);
}

class FileMoveError extends AppError {
  const FileMoveError({String? detail})
      : super("Couldn't move the file.", technicalDetail: detail);
}

class FileDeleteError extends AppError {
  const FileDeleteError({String? detail})
      : super("Couldn't delete the file.", technicalDetail: detail);
}

class ScanFileError extends AppError {
  final String filePath;

  const ScanFileError({required this.filePath, String? detail})
      : super('This file is unsupported.', technicalDetail: detail);
}

class PermissionError extends AppError {
  const PermissionError({String? detail})
      : super('Music access is required to scan your library.',
            technicalDetail: detail);
}

class DatabaseError extends AppError {
  const DatabaseError({String? detail})
      : super('Something went wrong with your library.',
            technicalDetail: detail);
}
