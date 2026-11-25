import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/formatting/app_formatters.dart';
import 'package:leaderapp/core/formatting/event_time_zones.dart';

/// CLDR separates the time from AM/PM with U+202F; compare with plain spaces.
String _n(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

Duration h(int hours, [int minutes = 0]) =>
    Duration(hours: hours, minutes: hours < 0 ? -minutes : minutes);

void main() {
  const en = AppFormatters();

  setUpAll(() async {
    await AppFormatters.initialize();
  });

  group('EventTimeZones.offsetAt (IANA, DST-aware, UTC input)', () {
    test('India has no DST: +5:30 all year (not hard-coded: it is looked up)', () {
      expect(EventTimeZones.offsetAt('Asia/Kolkata', DateTime.utc(2026, 1, 15)), h(5, 30));
      expect(EventTimeZones.offsetAt('Asia/Kolkata', DateTime.utc(2026, 7, 15)), h(5, 30));
    });

    test('New York: EST in winter, EDT in summer', () {
      expect(EventTimeZones.offsetAt('America/New_York', DateTime.utc(2026, 1, 15, 12)), h(-5));
      expect(EventTimeZones.offsetAt('America/New_York', DateTime.utc(2026, 7, 15, 12)), h(-4));
    });

    test('exact DST boundaries (US 2026: starts Mar 8 07:00Z, ends Nov 1 06:00Z)', () {
      const ny = 'America/New_York';
      expect(EventTimeZones.offsetAt(ny, DateTime.utc(2026, 3, 8, 6, 59, 59)), h(-5));
      expect(EventTimeZones.offsetAt(ny, DateTime.utc(2026, 3, 8, 7, 0, 0)), h(-4));
      expect(EventTimeZones.offsetAt(ny, DateTime.utc(2026, 11, 1, 5, 59, 59)), h(-4));
      expect(EventTimeZones.offsetAt(ny, DateTime.utc(2026, 11, 1, 6, 0, 0)), h(-5));
    });

    test('Europe/London: GMT in winter, BST in summer', () {
      expect(EventTimeZones.offsetAt('Europe/London', DateTime.utc(2026, 1, 15)), Duration.zero);
      expect(EventTimeZones.offsetAt('Europe/London', DateTime.utc(2026, 7, 15)), h(1));
    });

    test('southern hemisphere is reversed (Sydney)', () {
      expect(EventTimeZones.offsetAt('Australia/Sydney', DateTime.utc(2026, 12, 15)), h(11));
      expect(EventTimeZones.offsetAt('Australia/Sydney', DateTime.utc(2026, 6, 15)), h(10));
    });

    test('other zones: Dubai +4, Kathmandu +5:45, Chatham +12:45/+13:45', () {
      expect(EventTimeZones.offsetAt('Asia/Dubai', DateTime.utc(2026, 7, 1)), h(4));
      expect(EventTimeZones.offsetAt('Asia/Kathmandu', DateTime.utc(2026, 7, 1)), h(5, 45));
      expect(EventTimeZones.offsetAt('Pacific/Chatham', DateTime.utc(2026, 7, 1)), h(12, 45));
    });

    test('unknown, blank or null ids return null instead of guessing', () {
      expect(EventTimeZones.offsetAt('Mars/Phobos', DateTime.utc(2026, 1, 1)), isNull);
      expect(EventTimeZones.offsetAt('', DateTime.utc(2026, 1, 1)), isNull);
      expect(EventTimeZones.offsetAt('   ', DateTime.utc(2026, 1, 1)), isNull);
      expect(EventTimeZones.offsetAt(null, DateTime.utc(2026, 1, 1)), isNull);
    });

    test('ids are trimmed; a local (non-UTC) DateTime input is treated by instant', () {
      expect(EventTimeZones.offsetAt(' Asia/Kolkata ', DateTime.utc(2026, 1, 1)), h(5, 30));
      final local = DateTime.utc(2026, 7, 15, 12).toLocal();
      expect(EventTimeZones.offsetAt('America/New_York', local), h(-4));
    });

    test('wallClock gives the local wall time for the instant', () {
      final w = EventTimeZones.wallClock('Asia/Kolkata', DateTime.utc(2026, 12, 2, 15, 30))!;
      expect([w.hour, w.minute, w.day], [21, 0, 2]);
      expect(EventTimeZones.wallClock('Nope/Nope', DateTime.utc(2026, 1, 1)), isNull);
    });
  });

  group('AppFormatters.eventTime with ianaZone', () {
    final start = DateTime.utc(2026, 12, 2, 15, 30);
    final end = DateTime.utc(2026, 12, 2, 17, 0);

    test('one UTC instant presented in leaders\' different zones', () {
      expect(_n(en.eventTime(start, endUtc: end, ianaZone: 'Asia/Kolkata')),
          'Wed, Dec 2, 2026, 9:00 PM – 10:30 PM UTC+5:30');
      expect(_n(en.eventTime(start, endUtc: end, ianaZone: 'Asia/Dubai')),
          'Wed, Dec 2, 2026, 7:30 PM – 9:00 PM UTC+4');
      expect(_n(en.eventTime(start, endUtc: end, ianaZone: 'America/New_York')),
          'Wed, Dec 2, 2026, 10:30 AM – 12:00 PM UTC−5');
      expect(_n(en.eventTime(start, endUtc: end, ianaZone: 'Europe/London')),
          'Wed, Dec 2, 2026, 3:30 PM – 5:00 PM UTC');
    });

    test('the same wall time in a DST zone has a different offset in summer', () {
      final winter = DateTime.utc(2026, 1, 20, 18, 0); // 1:00 PM EST
      final summer = DateTime.utc(2026, 7, 20, 17, 0); // 1:00 PM EDT
      expect(_n(en.eventTime(winter, ianaZone: 'America/New_York')),
          'Tue, Jan 20, 2026, 1:00 PM UTC−5');
      expect(_n(en.eventTime(summer, ianaZone: 'America/New_York')),
          'Mon, Jul 20, 2026, 1:00 PM UTC−4');
    });

    test('an event that straddles a DST change shows both offsets', () {
      // 06:30Z = 1:30 AM EST (−5); 07:30Z = 3:30 AM EDT (−4)
      final s = DateTime.utc(2026, 3, 8, 6, 30);
      final e = DateTime.utc(2026, 3, 8, 7, 30);
      expect(_n(en.eventTime(s, endUtc: e, ianaZone: 'America/New_York')),
          'Sun, Mar 8, 2026, 1:30 AM – 3:30 AM UTC−5 → UTC−4');
    });

    test('crossing midnight in the zone shows the end date', () {
      final s = DateTime.utc(2026, 12, 2, 18, 0); // 23:30 IST
      final e = DateTime.utc(2026, 12, 2, 19, 0); // 00:30 IST next day
      expect(_n(en.eventTime(s, endUtc: e, ianaZone: 'Asia/Kolkata')),
          'Wed, Dec 2, 2026, 11:30 PM – Thu, Dec 3, 2026, 12:30 AM UTC+5:30');
    });

    test('showZoneId appends the IANA id only for a known zone', () {
      expect(_n(en.eventTime(start, ianaZone: 'Asia/Kolkata', showZoneId: true)),
          'Wed, Dec 2, 2026, 9:00 PM UTC+5:30 · Asia/Kolkata');
      expect(
        _n(en.eventTime(start,
            ianaZone: 'Mars/Phobos', zoneOffset: h(4), showZoneId: true)),
        'Wed, Dec 2, 2026, 7:30 PM UTC+4', // unknown id: ignored, offset used
      );
    });

    test('showViewerTime adds the viewer\'s clock only when it differs', () {
      expect(
        _n(en.eventTime(start,
            ianaZone: 'Asia/Kolkata',
            showViewerTime: true,
            viewerOffset: h(4))), // leader abroad in Dubai
        'Wed, Dec 2, 2026, 9:00 PM UTC+5:30 (your time: 7:30 PM UTC+4)',
      );
      expect(
        _n(en.eventTime(start,
            ianaZone: 'Asia/Kolkata',
            showViewerTime: true,
            viewerOffset: h(5, 30))),
        'Wed, Dec 2, 2026, 9:00 PM UTC+5:30', // same zone: nothing extra
      );
    });

    test('priority: IANA id > fixed offset > device zone', () {
      expect(_n(en.eventTime(start, ianaZone: 'Asia/Dubai', zoneOffset: h(9))),
          'Wed, Dec 2, 2026, 7:30 PM UTC+4');
      expect(_n(en.eventTime(start, ianaZone: '', zoneOffset: h(9))),
          'Thu, Dec 3, 2026, 12:30 AM UTC+9');
      expect(en.eventTime(start), matches(RegExp(r'UTC([+−]\d+(:\d\d)?)?$')));
    });
  });
}
