import 'package:flutter/material.dart';

/// Gaan Shuni color palette.
///
/// Design direction: calm navy background with indigo-violet accent,
/// matching the app icon's blue-to-purple gradient aesthetic.
/// Distinctly Gaan Shuni — not a Spotify or YT Music clone.
class AppColors {
  AppColors._();

  // ─── Brand Accent ───
  static const Color accent = Color(0xFF6366F1); // Indigo-500
  static const Color accentLight = Color(0xFF818CF8); // Indigo-400
  static const Color accentDark = Color(0xFF4F46E5); // Indigo-600

  // ─── Light Theme ───
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F5);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF2D2D3A);
  static const Color lightSubtle = Color(0xFF9898A8);
  static const Color lightDivider = Color(0xFFE8E8F0);

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF1E1E2A);
  static const Color darkOnBackground = Color(0xFFE8E8F0);
  static const Color darkOnSurface = Color(0xFFE0E0E8);
  static const Color darkSubtle = Color(0xFF6A6A7A);
  static const Color darkDivider = Color(0xFF2A2A3A);

  // ─── Semantic ───
  static const Color error = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);

  // ─── Artwork Fallback Gradients ───
  /// Used to generate gradient backgrounds when album artwork is unavailable.
  /// Each entry is [startColor, endColor]. A song's hash selects the gradient.
  static const List<List<Color>> artworkGradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFF3B82F6), Color(0xFF6366F1)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF14B8A6), Color(0xFF3B82F6)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
  ];

  /// Returns a gradient pair based on a hash value (e.g., song title hash).
  static List<Color> gradientForHash(int hash) {
    final index = hash.abs() % artworkGradients.length;
    return artworkGradients[index];
  }
}
