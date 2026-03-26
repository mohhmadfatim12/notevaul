/// Input validation utilities for NoteVault.
class Validators {
  Validators._();

  /// Returns true if note contains either non-empty title or non-empty body.
  static bool isValidNote({required String title, required String body}) {
    return title.trim().isNotEmpty || body.trim().isNotEmpty;
  }

  /// Validates folder name. Returns error message or null if valid.
  static String? validateFolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Folder name cannot be empty';
    }
    if (value.trim().length > 50) {
      return 'Folder name must be under 50 characters';
    }
    return null;
  }

  /// Validates tag name. Returns error message or null if valid.
  static String? validateTagName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tag name cannot be empty';
    }
    final sanitized = value.trim();
    if (sanitized.length > 30) {
      return 'Tag name must be under 30 characters';
    }
    if (sanitized.contains(',') || sanitized.contains('#')) {
      return 'Tag name cannot contain commas or hash symbols';
    }
    return null;
  }

  /// Validates PIN string.
  static String? validatePin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return 'PIN cannot be empty';
    }
    if (value.length != length) {
      return 'PIN must be exactly $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain digits only';
    }
    return null;
  }
}
