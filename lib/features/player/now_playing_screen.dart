import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';

import '../../core/utils/duration_formatter.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/song_repository.dart';
import '../../widgets/artwork_widget.dart';
import 'player_provider.dart';
import 'queue_sheet.dart';

/// Full-screen Now Playing screen with large artwork, playback controls, and queue sheet access.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = context.watch<PlayerProvider>();
    final songRepo = context.read<SongRepository>();
    final song = player.currentSong;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No song currently playing')),
      );
    }

    final currentPosMs = player.position.inMilliseconds;
    final totalDurMs = player.duration.inMilliseconds > 0
        ? player.duration.inMilliseconds
        : song.durationMs;
    final progress = totalDurMs > 0
        ? (currentPosMs / totalDurMs).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => QueueSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(),
              // Large Artwork
              Center(
                child: Hero(
                  tag: 'current_artwork',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ArtworkWidget(
                      songId: song.id,
                      size: MediaQuery.of(context).size.width * 0.75,
                      borderRadius: 24,
                      fallbackIcon: Icons.music_note_rounded,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Song Info and Favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${song.artist} • ${song.album}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      song.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: song.isFavorite ? Colors.redAccent : theme.hintColor,
                      size: 28,
                    ),
                    onPressed: () async {
                      await songRepo.toggleFavorite(song.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Seek Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (val) {
                        final newPosMs = (val * totalDurMs).toInt();
                        player.seek(Duration(milliseconds: newPosMs));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DurationFormatter.format(currentPosMs),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          DurationFormatter.format(totalDurMs),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Playback Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: player.isShuffle
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                    ),
                    onPressed: player.toggleShuffle,
                  ),
                  // Previous
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: player.skipToPrevious,
                  ),
                  // Play/Pause
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 36,
                      color: Colors.white,
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: player.togglePlayPause,
                    ),
                  ),
                  // Next
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: player.skipToNext,
                  ),
                  // Repeat
                  IconButton(
                    icon: Icon(
                      switch (player.repeatMode) {
                        RepeatMode.off => Icons.repeat_rounded,
                        RepeatMode.all => Icons.repeat_rounded,
                        RepeatMode.one => Icons.repeat_one_rounded,
                      },
                      color: player.repeatMode != RepeatMode.off
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                    ),
                    onPressed: player.cycleRepeatMode,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
