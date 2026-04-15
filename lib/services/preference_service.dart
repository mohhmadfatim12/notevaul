import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';

/// Centralized offline preferences manager.
class PreferenceService {
  final SharedPreferences prefs;

  PreferenceService(this.prefs);

  static const String keyThemeMode = 'nv_theme_mode';
  static const String keyAccentColor = 'nv_accent_color';
  static const String keyDefaultSort = 'nv_default_sort';
  static const String keyDefaultNoteColor = 'nv_default_note_color';
  static const String keyEditorFontSize = 'nv_editor_font_size';
  static const String keyAutoSaveEnabled = 'nv_auto_save_enabled';
  static const String keyConfirmDelete = 'nv_confirm_delete';
  static const String keyOnboardingCompleted = 'nv_onboarding_completed';
  static const String keyPinLockEnabled = 'nv_pin_lock_enabled';
  static const String keyHashedPin = 'nv_hashed_pin';
  static const String keyBiometricEnabled = 'nv_biometric_enabled';
  static const String keyAutoLockTimeoutMinutes = 'nv_auto_lock_timeout';

  // Theme Mode
  ThemeMode getThemeMode() {
    final value = prefs.getString(keyThemeMode);
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString(keyThemeMode, value);
  }

  // Accent Color
  Color getAccentColor() {
    final value = prefs.getInt(keyAccentColor);
    if (value != null) return Color(value);
    return const Color(0xFF3F51B5);
  }

  Future<void> setAccentColor(Color color) async {
    await prefs.setInt(keyAccentColor, color.toARGB32());
  }

  // Default Sort
  NoteSortOption getDefaultSort() {
    final index = prefs.getInt(keyDefaultSort) ?? 0;
    if (index >= 0 && index < NoteSortOption.values.length) {
      return NoteSortOption.values[index];
    }
    return NoteSortOption.newestUpdated;
  }

  Future<void> setDefaultSort(NoteSortOption sort) async {
    await prefs.setInt(keyDefaultSort, sort.index);
  }

  // Default Note Color
  int getDefaultNoteColor() => prefs.getInt(keyDefaultNoteColor) ?? 0;

  Future<void> setDefaultNoteColor(int colorId) async {
    await prefs.setInt(keyDefaultNoteColor, colorId);
  }

  // Editor Font Size
  double getEditorFontSize() => prefs.getDouble(keyEditorFontSize) ?? 16.0;

  Future<void> setEditorFontSize(double size) async {
    await prefs.setDouble(keyEditorFontSize, size);
  }

  // Auto-Save
  bool isAutoSaveEnabled() => prefs.getBool(keyAutoSaveEnabled) ?? true;

  Future<void> setAutoSaveEnabled(bool enabled) async {
    await prefs.setBool(keyAutoSaveEnabled, enabled);
  }

  // Confirm Delete
  bool isConfirmDeleteEnabled() => prefs.getBool(keyConfirmDelete) ?? true;

  Future<void> setConfirmDeleteEnabled(bool enabled) async {
    await prefs.setBool(keyConfirmDelete, enabled);
  }

  // Onboarding
  bool isOnboardingCompleted() =>
      prefs.getBool(keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(keyOnboardingCompleted, completed);
  }

  // Security - PIN
  bool isPinLockEnabled() => prefs.getBool(keyPinLockEnabled) ?? false;

  Future<void> setPinLockEnabled(bool enabled) async {
    await prefs.setBool(keyPinLockEnabled, enabled);
  }

  String? getHashedPin() => prefs.getString(keyHashedPin);

  Future<void> setHashedPin(String? hash) async {
    if (hash == null) {
      await prefs.remove(keyHashedPin);
    } else {
      await prefs.setString(keyHashedPin, hash);
    }
  }

  // Security - Biometrics
  bool isBiometricEnabled() => prefs.getBool(keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    await prefs.setBool(keyBiometricEnabled, enabled);
  }

  // Security - Auto-Lock Inactivity Timeout (minutes; 0 = immediate on background)
  int getAutoLockTimeoutMinutes() =>
      prefs.getInt(keyAutoLockTimeoutMinutes) ?? 0;

  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    await prefs.setInt(keyAutoLockTimeoutMinutes, minutes);
  }

  /// Clears all preferences
  Future<void> clearAll() async {
    await prefs.clear();
  }
}
