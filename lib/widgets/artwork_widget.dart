import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../core/theme/app_colors.dart';

/// Reusable artwork thumbnail/cover widget with graceful gradient fallback.
class ArtworkWidget extends StatelessWidget {
  final int songId;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;

  const ArtworkWidget({
    super.key,
    required this.songId,
    this.size = 48.0,
    this.borderRadius = 8.0,
    this.fallbackIcon = Icons.music_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile && songId > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: QueryArtworkWidget(
          id: songId,
          type: ArtworkType.AUDIO,
          artworkWidth: size,
          artworkHeight: size,
          artworkFit: BoxFit.cover,
          nullArtworkWidget: _buildFallback(context),
          errorBuilder: (_, _, _) => _buildFallback(context),
        ),
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final gradientColors = AppColors.gradientForHash(songId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.5,
          color: Colors.white.withAlpha(220),
        ),
      ),
    );
  }
}
