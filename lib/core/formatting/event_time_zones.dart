import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// IANA time-zone lookups with correct daylight-saving behaviour.
///
/// Instants are always handled as **UTC** (how the backend stores them); a zone
/// is only used to *present* an instant. Zone ids come from the backend (e.g.
/// `Asia/Kolkata`, `Europe/London`, `America/New_York`); nothing here assumes a
/// particular country. An unknown or empty id yields `null` so callers can fall
/// back to an explicit offset or the device zone instead of guessing.
class EventTimeZones {
  EventTimeZones._();

  static bool _ready = false;

  /// Loads the full tz database once (idempotent, a few ms). Called lazily.
  static void ensureInitialized() {
    if (_ready) return;
    tzdata.initializeTimeZones();
    _ready = true;
  }

  /// The zone for [ianaId], or `null` when it is blank or not a known IANA id.
  static tz.Location? tryLocation(String? ianaId) {
    final id = ianaId?.trim();
    if (id == null || id.isEmpty) return null;
    ensureInitialized();
    try {
      return tz.getLocation(id);
    } on tz.LocationNotFoundException {
      return null;
    }
  }

  /// UTC offset of [ianaId] at the UTC instant [utc] (DST-aware), or `null`
  /// for an unknown zone.
  static Duration? offsetAt(String? ianaId, DateTime utc) {
    final loc = tryLocation(ianaId);
    if (loc == null) return null;
    return tz.TZDateTime.fromMillisecondsSinceEpoch(
      loc,
      utc.toUtc().millisecondsSinceEpoch,
    ).timeZoneOffset;
  }

  /// The wall-clock time of the UTC instant [utc] in [ianaId] as a plain
  /// `DateTime` (fields are the local wall time; `isUtc` is `true` only so
  /// that no further device-zone conversion is applied), or `null` for an
  /// unknown zone.
  static DateTime? wallClock(String? ianaId, DateTime utc) {
    final off = offsetAt(ianaId, utc);
    if (off == null) return null;
    return utc.toUtc().add(off);
  }
}
