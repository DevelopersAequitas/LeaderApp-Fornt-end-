import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'event_time_zones.dart';
import 'money.dart';

/// Locale-aware number, currency, date and event-time formatting.
///
/// English (`en`) is the default; no other languages are enabled until an
/// approved language list exists. Pass a different [localeName] (e.g. `en_IN`,
/// `de`, `ar`) to format for that locale — for locales other than `en` call
/// `initializeDateFormatting(localeName)` once at start-up first (dates only).
///
/// This class is a foundation: it is **not wired into screens yet**, so
/// existing output (e.g. `₹13L`) is unchanged.
class AppFormatters {
  const AppFormatters({this.localeName = 'en'});

  final String localeName;

  /// `intl` throws `LocaleDataException` for date formats (even English) until
  /// the locale's date symbols are loaded. Call once at start-up (and in tests)
  /// before using the date/time methods: `await AppFormatters.initialize()`.
  /// Also loads the tz database used for IANA-zone event times.
  static Future<void> initialize([String locale = 'en']) async {
    await initializeDateFormatting(locale);
    EventTimeZones.ensureInitialized();
  }

  // ---------------------------------------------------------------- numbers

  /// `1234567.891` → `1,234,567.89` (grouping/decimal marks follow the locale).
  String number(num value, {int decimals = 0}) {
    final f = NumberFormat.decimalPatternDigits(
      locale: localeName,
      decimalDigits: decimals,
    );
    return f.format(value);
  }

  /// Compact form: `13000` → `13K`, `1300000` → `1.3M` (locale rules).
  String compactNumber(num value) =>
      NumberFormat.compact(locale: localeName).format(value);

  /// `0.945` → `94.5%` (pass a fraction, not a percentage).
  String percent(num fraction, {int decimals = 1}) {
    final f = NumberFormat.decimalPercentPattern(
      locale: localeName,
      decimalDigits: decimals,
    );
    return f.format(fraction);
  }

  // --------------------------------------------------------------- currency

  /// Full currency amount using the currency's own symbol, e.g.
  /// `Money(72000,'INR')` → `₹72,000`, `Money(1250.5,'USD')` → `$1,250.50`.
  /// Fraction digits follow the currency (0 for JPY, 2 for USD, …).
  String money(Money value) {
    final f = NumberFormat.simpleCurrency(
      locale: localeName,
      name: value.currencyCode,
    );
    return f.format(value.amount);
  }

  /// Compact currency, e.g. `Money(1300000,'USD')` → `$1.3M`.
  String compactMoney(Money value) {
    final f = NumberFormat.compactSimpleCurrency(
      locale: localeName,
      name: value.currencyCode,
    );
    return f.format(value.amount);
  }

  /// Formats a possibly-unavailable amount. `null` → [unavailable] (default
  /// `Unavailable`), never a fabricated zero.
  String moneyOrUnavailable(Money? value, {String unavailable = 'Unavailable'}) =>
      value == null ? unavailable : money(value);

  // ------------------------------------------------------------------ dates

  /// `2026-12-02` → `Dec 2, 2026` (order/month names follow the locale).
  String date(DateTime value) => DateFormat.yMMMd(localeName).format(value);

  /// `Wed, Dec 2, 2026`.
  String dateWithWeekday(DateTime value) =>
      DateFormat.yMMMEd(localeName).format(value);

  /// `9:00 PM` / `21:00` depending on the locale's 12/24-hour convention.
  String time(DateTime value) => DateFormat.jm(localeName).format(value);

  /// `Dec 2, 2026 9:00 PM` (the separator follows the locale's CLDR pattern).
  String dateTime(DateTime value) =>
      DateFormat.yMMMd(localeName).add_jm().format(value);

  // ---------------------------------------------------- timezone-aware events

  /// Formats an event start (and optional end) given as **UTC instants**.
  ///
  /// Which zone the event is shown in, in order of preference:
  /// 1. [ianaZone] — the Circle/event's real IANA id from the backend
  ///    (`Asia/Kolkata`, `Europe/London`, `America/New_York`, …). Offsets are
  ///    resolved from the tz database **at that instant**, so daylight-saving
  ///    changes are correct, including events that straddle a DST change
  ///    (start and end may have different offsets). An unknown id is ignored.
  /// 2. [zoneOffset] — a fixed offset supplied by the backend.
  /// 3. The device's zone, labelled with its current offset.
  ///
  /// The result always carries an explicit `UTC±h[:mm]` label so a time is never
  /// ambiguous. Pass [showZoneId] to append the IANA id (useful where several
  /// zones share an offset), and [showViewerTime] to append the viewer's own
  /// time when it differs from the event's zone (a leader abroad).
  ///
  /// Nothing here assumes a particular country or hardcodes IST.
  String eventTime(
    DateTime startUtc, {
    DateTime? endUtc,
    String? ianaZone,
    Duration? zoneOffset,
    bool showZoneId = false,
    bool showViewerTime = false,
    Duration? viewerOffset,
  }) {
    final start = startUtc.toUtc();
    final end = endUtc?.toUtc();

    final knownZone = EventTimeZones.tryLocation(ianaZone) != null;
    Duration offsetFor(DateTime instant) =>
        (knownZone ? EventTimeZones.offsetAt(ianaZone, instant) : null) ??
        zoneOffset ??
        instant.toLocal().timeZoneOffset;

    final startOffset = offsetFor(start);
    final shownStart = start.add(startOffset);
    final startLabel = utcLabel(startOffset);

    final datePart = DateFormat.yMMMEd(localeName).format(shownStart);
    final startPart = DateFormat.jm(localeName).format(shownStart);

    String out;
    if (end == null) {
      out = '$datePart, $startPart $startLabel';
    } else {
      final endOffset = offsetFor(end);
      final shownEnd = end.add(endOffset);
      final endLabel = utcLabel(endOffset);
      final endPart = DateFormat.jm(localeName).format(shownEnd);
      final sameDay = shownStart.year == shownEnd.year &&
          shownStart.month == shownEnd.month &&
          shownStart.day == shownEnd.day;
      // If daylight saving changes between start and end, show both labels.
      final labels = startLabel == endLabel ? endLabel : '$startLabel → $endLabel';
      if (sameDay) {
        out = '$datePart, $startPart – $endPart $labels';
      } else {
        final endDate = DateFormat.yMMMEd(localeName).format(shownEnd);
        out = '$datePart, $startPart – $endDate, $endPart $labels';
      }
    }

    if (showZoneId && knownZone) out += ' · ${ianaZone!.trim()}';

    if (showViewerTime) {
      final viewer = viewerOffset ?? start.toLocal().timeZoneOffset;
      if (viewer != startOffset) {
        final v = start.add(viewer);
        out += ' (your time: ${DateFormat.jm(localeName).format(v)} '
            '${utcLabel(viewer)})';
      }
    }
    return out;
  }

  /// `Duration(hours:5, minutes:30)` → `UTC+5:30`; `Duration.zero` → `UTC`.
  static String utcLabel(Duration offset) {
    if (offset == Duration.zero) return 'UTC';
    final negative = offset.isNegative;
    final abs = offset.abs();
    final h = abs.inHours;
    final m = abs.inMinutes.remainder(60);
    final sign = negative ? '−' : '+';
    return m == 0
        ? 'UTC$sign$h'
        : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
  }
}
