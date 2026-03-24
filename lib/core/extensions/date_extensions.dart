import 'package:intl/intl.dart';

/// DateTime extensions for human-friendly formatting and trash expiry calculation.
extension DateExtensions on DateTime {
  /// Formats date into relative string: 'Today, 2:30 PM', 'Yesterday, 11:00 AM', or 'Oct 25, 2026'.
  String formatRelative() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(year, month, day);

    if (aDate == today) {
      return 'Today, ${DateFormat.jm().format(this)}';
    } else if (aDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat.jm().format(this)}';
    } else if (now.year == year) {
      return DateFormat('MMM d, h:mm a').format(this);
    } else {
      return DateFormat('MMM d, yyyy').format(this);
    }
  }

  /// Formats date for cards and lists (e.g. 'Oct 27, 2026').
  String formatDate() => DateFormat('MMM d, yyyy').format(this);

  /// Formats time (e.g. '4:30 PM').
  String formatTime() => DateFormat.jm().format(this);

  /// Formats full timestamp for exports and backups.
  String formatFull() => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  /// Checks if date falls within the current calendar week.
  bool isThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final normalizedStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = normalizedStart.add(const Duration(days: 7));
    return isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek);
  }

  /// Calculates days remaining before a trashed item expires (30-day policy).
  int daysRemainingInTrash({int expiryDays = 30}) {
    final elapsedDays = DateTime.now().difference(this).inDays;
    final remaining = expiryDays - elapsedDays;
    return remaining > 0 ? remaining : 0;
  }
}
