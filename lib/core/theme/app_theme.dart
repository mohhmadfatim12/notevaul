import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// AppTheme facade providing theme data and settings.
class AppTheme {
  AppTheme._();

  static ThemeData light({Color? accentColor}) =>
      getLightTheme(primaryColor: accentColor ?? const Color(0xFF3F51B5));

  static ThemeData dark({Color? accentColor}) =>
      getDarkTheme(primaryColor: accentColor ?? const Color(0xFF3F51B5));

  static const List<Color> accentColorOptions = [
    Color(0xFF3F51B5), // Indigo
    Color(0xFF1E88E5), // Blue
    Color(0xFF00897B), // Teal
    Color(0xFF43A047), // Green
    Color(0xFFFFB300), // Amber
    Color(0xFFE53935), // Red
    Color(0xFF8E24AA), // Purple
    Color(0xFF546E7A), // Slate
  ];
}
