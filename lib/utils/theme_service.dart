import 'package:flutter/material.dart';

class ThemeService {
  static ThemeData getLightTheme() {
    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleMedium: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    );
  }

  static Color getGlassColor() => Colors.white.withOpacity(0.08);
  static Color getGlassBorderColor() => Colors.white.withOpacity(0.2);

  static List<List<Color>> getGradientSets() {
    return [
      [Colors.purple, Colors.blue], // Default
      [Colors.pink, Colors.orange], // Warm
      [Colors.blue, Colors.teal], // Cool
      [Colors.deepPurple, Colors.pink], // Royal
      [Colors.red, Colors.deepPurple], // Sunset
    ];
  }
}
