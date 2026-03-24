/// String extensions for productivity analytics: word count, reading time, truncation.
extension StringExtensions on String {
  /// Returns the number of words separated by whitespace.
  int get wordCount {
    final trimmed = trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Returns character count excluding trailing and leading whitespace.
  int get charCount => trim().length;

  /// Returns estimated reading time in minutes (assumes standard 200 WPM).
  int get estimatedReadingTimeMinutes {
    final count = wordCount;
    if (count == 0) return 0;
    final minutes = (count / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Returns formatted reading time string (e.g., "< 1 min read" or "3 min read").
  String get readingTimeFormatted {
    final count = wordCount;
    if (count == 0) return '0 min read';
    if (count < 200) return '< 1 min read';
    final minutes = (count / 200).ceil();
    return '$minutes min read';
  }

  /// Safely truncates string with an ellipsis if length exceeds maxLength.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
