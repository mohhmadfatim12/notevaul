import 'package:flutter/material.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';
import 'package:notevault/services/preference_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferenceService _prefService;

  late ThemeMode _themeMode;
  late Color _accentColor;
  late NoteSortOption _defaultSort;
  late int _defaultNoteColor;
  late double _editorFontSize;
  late bool _isAutoSaveEnabled;
  late bool _isConfirmDeleteEnabled;
  late bool _isOnboardingCompleted;
  late bool _isPinLockEnabled;
  late bool _isBiometricEnabled;
  late int _autoLockTimeoutMinutes;

  SettingsProvider(this._prefService) {
    _loadSettings();
  }

  void _loadSettings() {
    _themeMode = _prefService.getThemeMode();
    _accentColor = _prefService.getAccentColor();
    _defaultSort = _prefService.getDefaultSort();
    _defaultNoteColor = _prefService.getDefaultNoteColor();
    _editorFontSize = _prefService.getEditorFontSize();
    _isAutoSaveEnabled = _prefService.isAutoSaveEnabled();
    _isConfirmDeleteEnabled = _prefService.isConfirmDeleteEnabled();
    _isOnboardingCompleted = _prefService.isOnboardingCompleted();
    _isPinLockEnabled = _prefService.isPinLockEnabled();
    _isBiometricEnabled = _prefService.isBiometricEnabled();
    _autoLockTimeoutMinutes = _prefService.getAutoLockTimeoutMinutes();
  }

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  NoteSortOption get defaultSort => _defaultSort;
  int get defaultNoteColor => _defaultNoteColor;
  double get editorFontSize => _editorFontSize;
  bool get isAutoSaveEnabled => _isAutoSaveEnabled;
  bool get isConfirmDeleteEnabled => _isConfirmDeleteEnabled;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isPinLockEnabled => _isPinLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get autoLockTimeoutMinutes => _autoLockTimeoutMinutes;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefService.setThemeMode(mode);
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    await _prefService.setAccentColor(color);
  }

  Future<void> setDefaultSort(NoteSortOption sort) async {
    _defaultSort = sort;
    notifyListeners();
    await _prefService.setDefaultSort(sort);
  }

  Future<void> setDefaultNoteColor(int colorId) async {
    _defaultNoteColor = colorId;
    notifyListeners();
    await _prefService.setDefaultNoteColor(colorId);
  }

  Future<void> setEditorFontSize(double size) async {
    _editorFontSize = size;
    notifyListeners();
    await _prefService.setEditorFontSize(size);
  }

  Future<void> setAutoSaveEnabled(bool enabled) async {
    _isAutoSaveEnabled = enabled;
    notifyListeners();
    await _prefService.setAutoSaveEnabled(enabled);
  }

  Future<void> setConfirmDeleteEnabled(bool enabled) async {
    _isConfirmDeleteEnabled = enabled;
    notifyListeners();
    await _prefService.setConfirmDeleteEnabled(enabled);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _isOnboardingCompleted = completed;
    notifyListeners();
    await _prefService.setOnboardingCompleted(completed);
  }

  Future<void> setPinLockEnabled(bool enabled) async {
    _isPinLockEnabled = enabled;
    notifyListeners();
    await _prefService.setPinLockEnabled(enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    notifyListeners();
    await _prefService.setBiometricEnabled(enabled);
  }

  Future<void> setAutoLockTimeoutMinutes(int minutes) async {
    _autoLockTimeoutMinutes = minutes;
    notifyListeners();
    await _prefService.setAutoLockTimeoutMinutes(minutes);
  }
}
