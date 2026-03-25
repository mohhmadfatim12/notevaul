/// Static date utility helpers for SQLite Unix timestamp conversion.
class AppDateUtils {
  AppDateUtils._();

  /// Converts milliseconds since epoch to DateTime. Returns null if timestamp is null.
  static DateTime? fromEpoch(int? epochMillis) {
    if (epochMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMillis);
  }

  /// Converts DateTime to milliseconds since epoch. Returns null if dateTime is null.
  static int? toEpoch(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }

  /// Current timestamp in Unix milliseconds.
  static int get currentEpoch => DateTime.now().millisecondsSinceEpoch;
}
