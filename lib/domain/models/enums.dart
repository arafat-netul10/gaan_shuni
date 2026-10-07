/// Repeat mode for playback.
enum RepeatMode {
  off,
  all,
  one;

  /// Cycles to the next repeat mode: off → all → one → off.
  RepeatMode get next => switch (this) {
        RepeatMode.off => RepeatMode.all,
        RepeatMode.all => RepeatMode.one,
        RepeatMode.one => RepeatMode.off,
      };
}

/// Sort field for song lists.
enum SortField {
  title,
  artist,
  album,
  dateAdded,
  duration,
  fileName,
  custom;
}

/// Sort direction.
enum SortOrder {
  ascending,
  descending;

  SortOrder get toggled => switch (this) {
        SortOrder.ascending => SortOrder.descending,
        SortOrder.descending => SortOrder.ascending,
      };
}
