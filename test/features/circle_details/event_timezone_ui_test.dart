import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/formatting/app_formatters.dart';
import 'package:leaderapp/core/formatting/event_time_display.dart';
import 'package:leaderapp/features/circle_details/model/circle_event_model.dart';
import 'package:leaderapp/features/circle_details/view/circle_event_detail_screen.dart';
import 'package:leaderapp/features/circle_details/view/widgets/circle_events_section.dart';
import 'package:leaderapp/features/circle_details/view/widgets/event_details_bottom_sheet.dart';
import 'package:leaderapp/features/peer_profile/model/peer_event_models.dart';

String _norm(String s) => s.replaceAll('\u202F', ' ').replaceAll('\u00A0', ' ');

void main() {
  setUpAll(() async {
    await AppFormatters.initialize();
  });

  group('EventTimeDisplay & model parsing', () {
    test(
      'formats the same UTC event accurately across different timezone locations',
      () {
        final base = {
          'id': 'ev-1',
          'title': 'Global Circle Conclave',
          'start_at': '2026-12-02T15:30:00Z',
          'end_at': '2026-12-02T17:00:00Z',
          'mode': 'Online',
          'status': 'Upcoming',
          'location': 'Zoom',
        };

        final ny = CircleEventModel.fromJson({
          ...base,
          'timezone': 'America/New_York',
        });
        final dubai = CircleEventModel.fromJson({
          ...base,
          'timezone': 'Asia/Dubai',
        });
        final kolkata = CircleEventModel.fromJson({
          ...base,
          'timezone': 'Asia/Kolkata',
        });
        final london = CircleEventModel.fromJson({
          ...base,
          'timezone': 'Europe/London',
        });

        expect(
          _norm(ny.formattedSchedule(showZoneId: true).fullLabel),
          'Wed, Dec 2, 2026, 10:30 AM – 12:00 PM UTC−5 · America/New_York',
        );
        expect(
          _norm(dubai.formattedSchedule(showZoneId: true).fullLabel),
          'Wed, Dec 2, 2026, 7:30 PM – 9:00 PM UTC+4 · Asia/Dubai',
        );
        expect(
          _norm(kolkata.formattedSchedule(showZoneId: true).fullLabel),
          'Wed, Dec 2, 2026, 9:00 PM – 10:30 PM UTC+5:30 · Asia/Kolkata',
        );
        expect(
          _norm(london.formattedSchedule(showZoneId: true).fullLabel),
          'Wed, Dec 2, 2026, 3:30 PM – 5:00 PM UTC · Europe/London',
        );
      },
    );

    test('handles DST transitions accurately (winter vs summer)', () {
      final winter = CircleEventModel.fromJson({
        'id': 'ev-winter',
        'title': 'Winter Conclave',
        'start_at': '2026-01-15T18:00:00Z',
        'end_at': '2026-01-15T19:00:00Z',
        'timezone': 'America/New_York',
        'mode': 'In-Person',
        'status': 'Upcoming',
        'location': 'New York',
      });
      final summer = CircleEventModel.fromJson({
        'id': 'ev-summer',
        'title': 'Summer Conclave',
        'start_at': '2026-07-15T18:00:00Z',
        'end_at': '2026-07-15T19:00:00Z',
        'timezone': 'America/New_York',
        'mode': 'In-Person',
        'status': 'Upcoming',
        'location': 'New York',
      });

      expect(
        _norm(winter.formattedSchedule().timeLabel),
        '1:00 PM – 2:00 PM UTC−5',
      );
      expect(
        _norm(summer.formattedSchedule().timeLabel),
        '2:00 PM – 3:00 PM UTC−4',
      );
    });

    test(
      'handles events crossing a DST boundary without losing either offset',
      () {
        // US 2026 DST starts Sun Mar 8 at 07:00Z (2:00 AM EST -> 3:00 AM EDT).
        final crossing = CircleEventModel.fromJson({
          'id': 'ev-dst-cross',
          'title': 'Overnight Strategy Session',
          'start_at': '2026-03-08T06:30:00Z',
          'end_at': '2026-03-08T07:30:00Z',
          'timezone': 'America/New_York',
          'mode': 'Online',
          'status': 'Upcoming',
          'location': 'Online',
        });

        final schedule = crossing.formattedSchedule(showZoneId: true);
        expect(_norm(schedule.timeLabel), '1:30 AM – 3:30 AM UTC−5 → UTC−4');
        expect(
          _norm(schedule.fullLabel),
          'Sun, Mar 8, 2026, 1:30 AM – 3:30 AM UTC−5 → UTC−4 · America/New_York',
        );
      },
    );

    test('reflects calendar date changes caused by timezone conversion', () {
      // 2026-07-15 23:30 UTC is Jul 15 7:30 PM in New York, but Jul 16 5:00 AM in Kolkata.
      final ny = CircleEventModel.fromJson({
        'id': 'ev-day-ny',
        'title': 'Cross-Border Brief',
        'start_at': '2026-07-15T23:30:00Z',
        'timezone': 'America/New_York',
        'mode': 'Online',
        'status': 'Upcoming',
        'location': 'Online',
      });
      final kolkata = CircleEventModel.fromJson({
        'id': 'ev-day-in',
        'title': 'Cross-Border Brief',
        'start_at': '2026-07-15T23:30:00Z',
        'timezone': 'Asia/Kolkata',
        'mode': 'Online',
        'status': 'Upcoming',
        'location': 'Online',
      });

      expect(_norm(ny.formattedSchedule().dateLabel), contains('Jul 15, 2026'));
      expect(_norm(ny.formattedSchedule().timeLabel), '7:30 PM UTC−4');
      expect(
        _norm(kolkata.formattedSchedule().dateLabel),
        contains('Jul 16, 2026'),
      );
      expect(_norm(kolkata.formattedSchedule().timeLabel), '5:00 AM UTC+5:30');
    });

    test(
      'handles missing or invalid timezone without misleading labels or date shifts',
      () {
        // Invalid IANA id with real UTC instant -> ignores bad zone id, falls back to offset/device.
        final badTz = CircleEventModel.fromJson({
          'id': 'ev-bad-tz',
          'title': 'Invalid TZ Event',
          'start_at': '2026-12-02T15:30:00+04:00',
          'timezone': 'Mars/Olympus',
          'mode': 'Online',
          'status': 'Upcoming',
          'location': 'Online',
        });
        final badSchedule = badTz.formattedSchedule(showZoneId: true);
        expect(badSchedule.timezoneId, isNull);
        expect(badSchedule.fullLabel, isNot(contains('Mars/Olympus')));
        expect(_norm(badSchedule.fullLabel), contains('UTC+4'));

        // Legacy date-only + wall-time string (no timestamp, no timezone):
        // never shifts the calendar date and never fabricates a UTC label.
        final legacy = CircleEventModel.fromJson({
          'id': 'ev-legacy',
          'title': 'Monthly Conclave',
          'date': '2026-12-02',
          'time': '10:00 AM',
          'mode': 'In-Person',
          'status': 'Upcoming',
          'location': 'Ahmedabad',
        });
        expect(legacy.startAtUtc, isNull);
        final legacySchedule = legacy.formattedSchedule(showZoneId: true);
        expect(legacySchedule.usedUtcTimestamp, isFalse);
        expect(legacySchedule.dateLabel, contains('Dec 2, 2026'));
        expect(legacySchedule.timeLabel, '10:00 AM');
        expect(legacySchedule.fullLabel, isNot(contains('UTC')));
      },
    );

    test('MemberEventItemModel parses UTC timestamps and timezone cleanly', () {
      final item = MemberEventItemModel.fromJson({
        'id': 'mev-1',
        'title': 'London Leadership Summit',
        'start_at': '2026-07-10T14:00:00Z',
        'end_at': '2026-07-10T16:00:00Z',
        'timezone': 'Europe/London',
        'status': 'upcoming',
      });
      final s = item.formattedSchedule(showZoneId: true);
      expect(s.usedUtcTimestamp, isTrue);
      expect(_norm(s.timeLabel), '3:00 PM – 5:00 PM UTC+1');
      expect(s.timezoneId, 'Europe/London');
    });

    test('parseIsoUtcInstant rejects date-only and time-only strings', () {
      expect(EventTimeDisplay.parseIsoUtcInstant('2026-12-02'), isNull);
      expect(EventTimeDisplay.parseIsoUtcInstant('10:00 AM'), isNull);
      expect(
        EventTimeDisplay.parseIsoUtcInstant('2026-12-02T15:30:00Z'),
        DateTime.utc(2026, 12, 2, 15, 30),
      );
    });
  });

  group('Event list and detail screen consistency', () {
    final dstCrossingEvent = CircleEventModel.fromJson({
      'id': 'ev-screen-1',
      'title': 'Transatlantic Leadership Forum',
      'start_at': '2026-03-08T06:30:00Z',
      'end_at': '2026-03-08T07:30:00Z',
      'timezone': 'America/New_York',
      'mode': 'Online',
      'status': 'Upcoming',
      'location': 'Virtual Room A',
      'attendees_count': 12,
    });

    testWidgets(
      'CircleEventsSection and CircleEventDetailScreen render consistent local time & DST transition',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CircleEventsSection(
                events: [dstCrossingEvent],
                allEvents: [dstCrossingEvent],
                isLoading: false,
                selectedFilter: 'All',
                onFilterChanged: (_) {},
              ),
            ),
          ),
        );

        final listTexts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => _norm(t.data ?? ''))
            .toList();
        expect(listTexts.any((t) => t.contains('Sun, Mar 8, 2026')), isTrue);
        expect(
          listTexts.any((t) => t.contains('1:30 AM – 3:30 AM UTC−5 → UTC−4')),
          isTrue,
        );

        // Now mount the Detail screen for the exact same event
        await tester.pumpWidget(
          MaterialApp(home: CircleEventDetailScreen(event: dstCrossingEvent)),
        );

        final detailTexts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => _norm(t.data ?? ''))
            .toList();
        expect(
          detailTexts.any(
            (t) =>
                t.contains('Sun, Mar 8, 2026') &&
                t.contains('1:30 AM – 3:30 AM UTC−5 → UTC−4') &&
                t.contains('America/New_York'),
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'EventDetailsBottomSheet uses the same shared timezone formatter',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EventDetailsBottomSheet(event: dstCrossingEvent),
            ),
          ),
        );

        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => _norm(t.data ?? ''))
            .toList();
        expect(
          texts.any(
            (t) =>
                t.contains('Sun, Mar 8, 2026') &&
                t.contains('1:30 AM – 3:30 AM UTC−5 → UTC−4'),
          ),
          isTrue,
        );
      },
    );
  });
}
