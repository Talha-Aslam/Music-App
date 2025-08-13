import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper class to generate placeholder album art
class AlbumArtGenerator {
  static Color getColorFromSongName(String songName) {
    // Generate a consistent color based on the song name
    final int hash = songName.hashCode;
    final random = math.Random(hash);

    // Create rich colors by ensuring at least one channel is strong
    int r = 100 + random.nextInt(155); // 100-255
    int g = 100 + random.nextInt(155); // 100-255
    int b = 100 + random.nextInt(155); // 100-255

    // Ensure at least one channel is very strong for vibrant colors
    final strongChannel = random.nextInt(3);
    if (strongChannel == 0) r = 200 + random.nextInt(55); // 200-255
    if (strongChannel == 1) g = 200 + random.nextInt(55); // 200-255
    if (strongChannel == 2) b = 200 + random.nextInt(55); // 200-255

    return Color.fromRGBO(r, g, b, 1.0);
  }

  static List<Color> getGradientColorsFromSongName(String songName) {
    final baseColor = getColorFromSongName(songName);
    final hsl = HSLColor.fromColor(baseColor);

    // Create complementary colors by shifting hue
    final complementary = hsl.withHue((hsl.hue + 180) % 360).toColor();
    final accent = hsl
        .withHue((hsl.hue + 120) % 360)
        .withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0))
        .toColor();

    return [baseColor, accent, complementary];
  }

  static String getInitials(String songName) {
    // Generate initials from song name
    final words = songName.split(RegExp(r'[ _\-.]'));
    String initials = '';

    // Get first letter of first two words, or first two letters if only one word
    if (words.length > 1) {
      if (words[0].isNotEmpty) initials += words[0][0].toUpperCase();
      if (words[1].isNotEmpty) initials += words[1][0].toUpperCase();
    } else if (words.isNotEmpty && words[0].length > 1) {
      initials =
          words[0].substring(0, math.min(2, words[0].length)).toUpperCase();
    } else {
      initials = 'MZ'; // Default: Music
    }

    return initials;
  }

  /// Get a widget to use as album art placeholder
  static Widget getPlaceholderWidget(String songName, {double size = 150}) {
    final colors = getGradientColorsFromSongName(songName);
    final initials = getInitials(songName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0], colors[1]],
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
