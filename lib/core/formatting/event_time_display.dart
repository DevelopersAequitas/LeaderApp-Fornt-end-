import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app_formatters.dart';
import 'event_time_zones.dart';

/// Structured display parts for an event's date, time, and timezone context.
///
/// Shared across event list cards, preview cards, detail screens, and bottom
/// sheets so every surface presents the exact same local date, time, DST
/// transition, and timezone context without duplicate formatting logic.
class FormattedEventSchedule {
  const FormattedEventSchedule({
    required this.dateLabel,
    required this.timeLabel,
    required this.fullLabel,
    this.timezoneId,
    this.usedUtcTimestamp = false,
  });

  /// Formatted date (and optional cadence), e.g. `Wed, Dec 2, 2026`.
  final String dateLabel;

  /// Formatted time range with explicit UTC offset when timestamp-backed, e.g.
  /// `9:00 PM – 10:30 PM UTC+5:30` or `1:30 AM – 3:30 AM UTC−5 → UTC−4`.
  final String timeLabel;

  /// Single combined display string suitable for detail rows and summaries.
  final String fullLabel;

  /// Validated IANA zone id (e.g. `America/New_York`), or `null` when absent
  /// or invalid. Invalid zone ids are never surfaced.
  final String? timezoneId;

  /// True when formatted from a real UTC timestamp rather than legacy
  /// zone-less local date/time strings.
  final bool usedUtcTimestamp;
}

/// Centralized event date/time formatter wired into Event screens.
///
/// Wraps [AppFormatters.eventTime] and [EventTimeZones] so:
/// - Timestamp-backed events convert UTC instants into the event's IANA zone
///   (with DST-correct offsets, including events straddling a DST change and
///   date rollovers), falling back to an explicit UTC offset, then device zone.
/// - Legacy zone-less calendar date (`2026-12-02`) + local wall-time (`10:00 AM`)
///   payloads never suffer spurious midnight-UTC date shifts and never display
///   a fabricated or misleading timezone label.
class EventTimeDisplay {
  EventTimeDisplay._();

  static final RegExp _isoOffsetPattern = RegExp(r'([+-])(\d{2}):?(\d{2})$');

  static final RegExp _dateOnlyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Parses an ISO-8601 timestamp **with a time component** (or epoch int)
  /// into a UTC [DateTime].
  ///
  /// Pure date-only strings like `'2026-12-02'` return `null` intentionally so
  /// they are not misread as `00:00:00Z` (which would shift calendar dates in
  /// negative UTC offsets).
  static DateTime? parseIsoUtcInstant(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toUtc();
    if (raw is int) {
      if (raw <= 0) return null;
      final ms = raw < 10000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    }

    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'None') return null;

    // Must contain a time component (ISO 'T' or HH:MM) to be a true instant.
    final hasTime = str.contains('T') || RegExp(r'\d{1,2}:\d{2}').hasMatch(str);
    if (!hasTime) return null;

    // Time-only strings without a date (e.g. "10:00 AM", "09:00:00") are not
    // UTC instants.
    final hasDate = RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(str);
    if (!hasDate) return null;

    var normalized = str.replaceFirst(' ', 'T');
    final hasZ = normalized.endsWith('Z') || normalized.endsWith('z');
    final hasOffset = _isoOffsetPattern.hasMatch(normalized);
    if (!hasZ && !hasOffset) {
      // Server datetime without offset is treated as UTC (matches DateTimeUtils).
      normalized = '${normalized}Z';
    }

    try {
      return DateTime.parse(normalized).toUtc();
    } catch (_) {
      return null;
    }
  }

  /// Extracts an explicit fixed UTC offset from an ISO-8601 timestamp string
  /// (e.g. `'2026-12-02T21:00:00+05:30'` → `Duration(hours: 5, minutes: 30)`).
  /// Returns `null` for `Z` or strings without an explicit numeric offset.
  static Duration? parseIsoOffset(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str.endsWith('Z') || str.endsWith('z')) return null;
    final match = _isoOffsetPattern.firstMatch(str);
    if (match == null) return null;
    final sign = match.group(1) == '-' ? -1 : 1;
    final hours = int.tryParse(match.group(2) ?? '');
    final minutes = int.tryParse(match.group(3) ?? '');
    if (hours == null || minutes == null || hours > 14 || minutes >= 60) {
      return null;
    }
    final totalMinutes = sign * (hours * 60 + minutes);
    return Duration(minutes: totalMinutes);
  }

  /// Parses an optional backend UTC offset value in minutes (e.g. `330` or `-300`).
  static Duration? parseOffsetMinutes(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) {
      final mins = raw.toInt();
      if (mins.abs() <= 14 * 60) return Duration(minutes: mins);
      return null;
    }
    final parsed = int.tryParse(raw.toString().trim());
    if (parsed != null && parsed.abs() <= 14 * 60) {
      return Duration(minutes: parsed);
    }
    return null;
  }

  /// Formats an event schedule using [AppFormatters.eventTime] and
  /// [EventTimeZones] when UTC timestamps are present, or cleanly formats
  /// legacy zone-less date/time fields without inventing timezone labels.
  static FormattedEventSchedule format({
    DateTime? startAtUtc,
    DateTime? endAtUtc,
    String? ianaZone,
    Duration? zoneOffset,
    String rawDate = '',
    String rawTime = '',
    String cadenceSummary = '',
    bool showZoneId = false,
    bool showViewerTime = false,
    Duration? viewerOffset,
    String localeName = 'en',
  }) {
    final effectiveLocale = _safeLocale(localeName);
    final validIana = EventTimeZones.tryLocation(ianaZone) != null
        ? ianaZone!.trim()
        : null;

    if (startAtUtc != null) {
      final start = startAtUtc.toUtc();
      final end = endAtUtc?.toUtc();

      Duration offsetFor(DateTime instant) =>
          (validIana != null
              ? EventTimeZones.offsetAt(validIana, instant)
              : null) ??
          zoneOffset ??
          instant.toLocal().timeZoneOffset;

      final startOffset = offsetFor(start);
      final shownStart = start.add(startOffset);
      final startLabel = AppFormatters.utcLabel(startOffset);

      final dateFmt = effectiveLocale != null
          ? DateFormat.yMMMEd(effectiveLocale)
          : DateFormat.yMMMEd();
      final timeFmt = effectiveLocale != null
          ? DateFormat.jm(effectiveLocale)
          : DateFormat.jm();

      final formattedDate = dateFmt.format(shownStart);
      final startTimeStr = timeFmt.format(shownStart);

      String timeLine;
      if (end == null) {
        timeLine = '$startTimeStr $startLabel';
      } else {
        final endOffset = offsetFor(end);
        final shownEnd = end.add(endOffset);
        final endLabel = AppFormatters.utcLabel(endOffset);
        final endTimeStr = timeFmt.format(shownEnd);
        final sameDay =
            shownStart.year == shownEnd.year &&
            shownStart.month == shownEnd.month &&
            shownStart.day == shownEnd.day;
        final offsetSummary = startLabel == endLabel
            ? endLabel
            : '$startLabel → $endLabel';
        if (sameDay) {
          timeLine = '$startTimeStr – $endTimeStr $offsetSummary';
        } else {
          final endDateStr = dateFmt.format(shownEnd);
          timeLine = '$startTimeStr – $endDateStr, $endTimeStr $offsetSummary';
        }
      }

      // Build the canonical full string via AppFormatters.eventTime when
      // locale data is ready, otherwise compose identically.
      String full;
      if (effectiveLocale != null) {
        full = AppFormatters(localeName: effectiveLocale).eventTime(
          start,
          endUtc: end,
          ianaZone: validIana,
          zoneOffset: zoneOffset,
          showZoneId: showZoneId,
          showViewerTime: showViewerTime,
          viewerOffset: viewerOffset,
        );
      } else {
        full = '$formattedDate, $timeLine';
        if (showZoneId && validIana != null) {
          full += ' · $validIana';
        }
        if (showViewerTime) {
          final viewer = viewerOffset ?? start.toLocal().timeZoneOffset;
          if (viewer != startOffset) {
            final v = start.add(viewer);
            full +=
                ' (your time: ${timeFmt.format(v)} ${AppFormatters.utcLabel(viewer)})';
          }
        }
      }

      final dateWithCadence = _appendCadence(formattedDate, cadenceSummary);
      return FormattedEventSchedule(
        dateLabel: dateWithCadence,
        timeLabel: timeLine,
        fullLabel: full,
        timezoneId: validIana,
        usedUtcTimestamp: true,
      );
    }

    // Legacy zone-less payload (e.g. date: "2026-12-02", time: "10:00 AM").
    // Never invent a UTC offset or shift a calendar date.
    final formattedDate = _formatLegacyDate(rawDate, effectiveLocale);
    final dateWithCadence = _appendCadence(formattedDate, cadenceSummary);
    final cleanTime = rawTime.trim();

    final timeWithZone =
        (cleanTime.isNotEmpty && showZoneId && validIana != null)
        ? '$cleanTime · $validIana'
        : cleanTime;

    final fullParts = <String>[
      dateWithCadence,
      if (cleanTime.isNotEmpty) cleanTime,
      if (showZoneId && validIana != null) validIana,
    ];

    return FormattedEventSchedule(
      dateLabel: dateWithCadence,
      timeLabel: timeWithZone,
      fullLabel: fullParts.join(' · '),
      timezoneId: validIana,
      usedUtcTimestamp: false,
    );
  }

  /// Returns [localeName] if `intl` date symbols are loaded for it, otherwise
  /// `null` so `DateFormat` safely uses its built-in default symbols without
  /// throwing `LocaleDataException` in tests where `initialize()` wasn't run.
  static String? _safeLocale(String localeName) {
    final map = dateTimeSymbolMap();
    if (map.containsKey(localeName)) return localeName;
    final short = localeName.split(RegExp(r'[_-]')).first;
    if (map.containsKey(short)) return short;
    return null;
  }

  static String _formatLegacyDate(String rawDate, String? effectiveLocale) {
    final trimmed = rawDate.trim();
    if (trimmed.isEmpty) return 'Date TBD';

    final match = _dateOnlyPattern.firstMatch(trimmed);
    if (match != null) {
      final y = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final d = int.parse(match.group(3)!);
      final calDate = DateTime(y, m, d);
      final fmt = effectiveLocale != null
          ? DateFormat.yMMMEd(effectiveLocale)
          : DateFormat.yMMMEd();
      return fmt.format(calDate);
    }

    return trimmed;
  }

  static String _appendCadence(String formattedDate, String cadenceSummary) {
    final c = cadenceSummary.trim();
    if (c.isEmpty ||
        formattedDate == 'Date TBD' ||
        formattedDate.toLowerCase().contains(c.toLowerCase())) {
      return formattedDate;
    }
    return '$formattedDate ($c)';
  }
}
