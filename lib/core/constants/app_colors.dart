import 'package:flutter/material.dart';

/// Centralized color palette for NoteVault.
/// All note colors are represented as 32-bit ARGB integers for safe SQLite storage.
class AppColors {
  AppColors._();

  // Brand Accents
  static const Color primary = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFFC5CAE9);
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFFB2DFDB);

  // Status & Priority
  static const Color favorite = Color(0xFFE91E63);
  static const Color pinned = Color(0xFFFF9800);
  static const Color reminder = Color(0xFF7E57C2);
  static const Color archived = Color(0xFF78909C);
  static const Color trash = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1E88E5);

  // Neutral Light
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F4);
  static const Color lightTextPrimary = Color(0xFF1F1F1F);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightCardBorder = Color(0xFFEBEBEB);

  // Neutral Dark
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFF1F3F4);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkCardBorder = Color(0xFF2A2A2A);

  // Note Color Options (Stored in SQLite as 32-bit int)
  static const List<NoteColorOption> noteColors = [
    NoteColorOption(
      id: 0,
      name: 'Default',
      lightColor: Color(0xFFFFFFFF),
      darkColor: Color(0xFF1E1E1E),
      borderColor: Color(0xFFCCCCCC),
    ),
    NoteColorOption(
      id: 1,
      name: 'Coral Red',
      lightColor: Color(0xFFFFEBEE),
      darkColor: Color(0xFF3E2723),
      borderColor: Color(0xFFEF9A9A),
    ),
    NoteColorOption(
      id: 2,
      name: 'Sunny Amber',
      lightColor: Color(0xFFFFF8E1),
      darkColor: Color(0xFF4E342E),
      borderColor: Color(0xFFFFE082),
    ),
    NoteColorOption(
      id: 3,
      name: 'Sage Mint',
      lightColor: Color(0xFFE8F5E9),
      darkColor: Color(0xFF1B5E20),
      borderColor: Color(0xFFA5D6A7),
    ),
    NoteColorOption(
      id: 4,
      name: 'Sky Teal',
      lightColor: Color(0xFFE0F7FA),
      darkColor: Color(0xFF004D40),
      borderColor: Color(0xFF80DEEA),
    ),
    NoteColorOption(
      id: 5,
      name: 'Lavender Blue',
      lightColor: Color(0xFFEDE7F6),
      darkColor: Color(0xFF311B92),
      borderColor: Color(0xFFB39DDB),
    ),
    NoteColorOption(
      id: 6,
      name: 'Blush Rose',
      lightColor: Color(0xFFFCE4EC),
      darkColor: Color(0xFF880E4F),
      borderColor: Color(0xFFF48FB1),
    ),
    NoteColorOption(
      id: 7,
      name: 'Slate Sand',
      lightColor: Color(0xFFECEFF1),
      darkColor: Color(0xFF263238),
      borderColor: Color(0xFFB0BEC5),
    ),
  ];

  static NoteColorOption getNoteColorById(int id) {
    return noteColors.firstWhere(
      (element) => element.id == id,
      orElse: () => noteColors[0],
    );
  }
}

class NoteColorOption {
  final int id;
  final String name;
  final Color lightColor;
  final Color darkColor;
  final Color borderColor;

  const NoteColorOption({
    required this.id,
    required this.name,
    required this.lightColor,
    required this.darkColor,
    required this.borderColor,
  });

  Color resolve(bool isDark) => isDark ? darkColor : lightColor;
}
