/// Centralized utility for parsing UTC dates/times and converting them to the device's local timezone.
class DateTimeUtils {
  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Parses any UTC date/time string, int timestamp, or DateTime object
  /// and converts it to the device's local timezone.
  static DateTime? parseUtc(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) {
      return raw.isUtc ? raw.toLocal() : raw;
    }
    if (raw is int) {
      if (raw <= 0) return null;
      // Handle seconds vs milliseconds
      final ms = raw < 10000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    }

    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'None') return null;

    var s = str;

    // Check if it has an explicit timezone (Z, +00:00, -05:00, etc.)
    final hasZ = s.endsWith('Z') || s.endsWith('z');
    final hasOffset = RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(s);

    if (!hasZ && !hasOffset) {
      // If it contains date + time without zone info, treat server response as UTC
      if (s.contains(' ') || s.contains('T')) {
        s = s.replaceAll(' ', 'T');
        s = '${s}Z';
      }
    }

    try {
      final parsed = DateTime.parse(s);
      return parsed.toLocal();
    } catch (_) {
      try {
        final fallback = DateTime.parse(str);
        return fallback.isUtc ? fallback.toLocal() : fallback;
      } catch (_) {
        return null;
      }
    }
  }

  /// Formats a date into relative time ("Just now", "5m ago", "2h ago", "3d ago", or "25 Sep 2026").
  static String formatTimeAgo(dynamic raw) {
    final dt = parseUtc(raw);
    if (dt == null) return raw?.toString() ?? '';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative || diff.inSeconds < 45) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }

    return formatDate(dt, shortMonth: true);
  }

  /// Formats date and time into local display string.
  /// E.g. "25 Sep 2026, 02:19 PM" or "25 Sep 2026"
  static String formatDateTime(
    dynamic raw, {
    bool includeTime = true,
    bool shortMonth = true,
  }) {
    final dt = parseUtc(raw);
    if (dt == null) return raw?.toString() ?? '';

    final datePart = formatDate(dt, shortMonth: shortMonth);
    if (!includeTime) return datePart;

    final timePart = formatTime(dt);
    return '$datePart, $timePart';
  }

  /// Formats local date part. E.g. "25 Sep 2026" or "25 September 2026"
  static String formatDate(dynamic raw, {bool shortMonth = true}) {
    final dt = parseUtc(raw);
    if (dt == null) return raw?.toString() ?? '';

    final day = dt.day.toString().padLeft(2, '0');
    final monthList = shortMonth ? _monthsShort : _monthsFull;
    final monthStr = monthList[dt.month - 1];
    final year = dt.year;

    return '$day $monthStr $year';
  }

  /// Formats local time part. E.g. "02:19 PM"
  static String formatTime(dynamic raw) {
    final dt = parseUtc(raw);
    if (dt == null) return raw?.toString() ?? '';

    final hourNum = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = hourNum.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$min $ampm';
  }
}

/// Extension on DateTime for convenient local formatting.
extension DateTimeTimezoneExtension on DateTime {
  String toTimeAgo() => DateTimeUtils.formatTimeAgo(this);
  String toFormattedDate({bool shortMonth = true}) =>
      DateTimeUtils.formatDate(this, shortMonth: shortMonth);
  String toFormattedDateTime({bool includeTime = true, bool shortMonth = true}) =>
      DateTimeUtils.formatDateTime(this,
          includeTime: includeTime, shortMonth: shortMonth);
  String toFormattedTime() => DateTimeUtils.formatTime(this);
}

/// Extension on String for convenient parsing and local formatting.
extension StringTimezoneExtension on String {
  DateTime? toLocalUtcDateTime() => DateTimeUtils.parseUtc(this);
  String toTimeAgo() => DateTimeUtils.formatTimeAgo(this);
  String toFormattedDate({bool shortMonth = true}) =>
      DateTimeUtils.formatDate(this, shortMonth: shortMonth);
  String toFormattedDateTime({bool includeTime = true, bool shortMonth = true}) =>
      DateTimeUtils.formatDateTime(this,
          includeTime: includeTime, shortMonth: shortMonth);
  String toFormattedTime() => DateTimeUtils.formatTime(this);
}
