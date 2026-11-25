import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leaderapp/core/formatting/app_formatters.dart';
import 'package:leaderapp/core/formatting/money.dart';

/// CLDR 42+ separates the time from AM/PM with U+202F (narrow no-break space);
/// compare with ordinary spaces so tests read naturally.
String _n(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_IN');
    await initializeDateFormatting('de');
    await initializeDateFormatting('ar');
  });

  const en = AppFormatters();

  group('numbers', () {
    test('English default: grouping, decimals, compact, percent', () {
      expect(en.number(1234567.891, decimals: 2), '1,234,567.89');
      expect(en.number(65000), '65,000');
      expect(en.compactNumber(13000), '13K');
      expect(en.compactNumber(1300000), '1.3M');
      expect(en.percent(0.945), '94.5%');
    });

    test('other locales use their own marks', () {
      expect(const AppFormatters(localeName: 'de').number(1234567.5, decimals: 1),
          '1.234.567,5');
      // Indian digit grouping for en_IN.
      expect(const AppFormatters(localeName: 'en_IN').number(1300000), '13,00,000');
    });
  });

  group('currency', () {
    test('uses the currency\'s own symbol and fraction digits', () {
      expect(en.money(const Money(72000, 'INR')), '₹72,000.00');
      expect(en.money(const Money(1250.5, 'USD')), r'$1,250.50');
      expect(en.money(const Money(1200, 'JPY')), '¥1,200');
    });

    test('compact currency', () {
      expect(en.compactMoney(const Money(1300000, 'USD')), r'$1.3M');
    });

    test('unavailable is explicit, never a fabricated zero', () {
      expect(en.moneyOrUnavailable(null), 'Unavailable');
      expect(en.moneyOrUnavailable(const Money(0, 'INR')), '₹0.00'); // real zero
      expect(en.moneyOrUnavailable(null, unavailable: '—'), '—');
    });

    test('different currencies are never added silently', () {
      expect(() => const Money(1, 'INR').plus(const Money(1, 'USD')),
          throwsArgumentError);
      expect(const Money(1, 'INR').plus(const Money(2, 'INR')),
          const Money(3, 'INR'));
    });
  });

  group('Money.tryParseFormatted (legacy strings)', () {
    test('parses the formats seen in the app', () {
      expect(Money.tryParseFormatted('₹72,000'), const Money(72000, 'INR'));
      expect(Money.tryParseFormatted('₹13L'), const Money(1300000, 'INR'));
      expect(Money.tryParseFormatted('₹22.5L'), const Money(2250000, 'INR'));
      expect(Money.tryParseFormatted('₹500.05Cr')?.amount, closeTo(5000500000, 1));
      expect(Money.tryParseFormatted('₹0')?.isZero, isTrue);
      expect(Money.tryParseFormatted(r'$1.2M'), const Money(1200000, 'USD'));
      expect(Money.tryParseFormatted('AED 4,500'), const Money(4500, 'AED'));
    });

    test('returns null for unknown text instead of inventing a value', () {
      for (final raw in [null, '', '  ', 'Unavailable', '72,000', '₹abc', '₹1X']) {
        expect(Money.tryParseFormatted(raw), isNull, reason: 'raw=$raw');
      }
    });
  });

  group('dates', () {
    final d = DateTime(2026, 12, 2, 21, 0);
    test('English default', () {
      expect(en.date(d), 'Dec 2, 2026');
      expect(en.dateWithWeekday(d), 'Wed, Dec 2, 2026');
      expect(_n(en.time(d)), '9:00 PM');
      expect(_n(en.dateTime(d)), 'Dec 2, 2026 9:00 PM');
    });

    test('other locales (day/month order, 24 h clock)', () {
      const de = AppFormatters(localeName: 'de');
      expect(de.date(d), '2. Dez. 2026');
      expect(de.time(d), '21:00');
    });
  });

  group('timezone-aware event presentation', () {
    // 2026-12-02 15:30 UTC == 21:00 in UTC+5:30.
    final startUtc = DateTime.utc(2026, 12, 2, 15, 30);
    final endUtc = DateTime.utc(2026, 12, 2, 17, 0);

    test('shows the Circle\'s own clock with an explicit offset label', () {
      expect(
        _n(en.eventTime(startUtc,
            endUtc: endUtc, zoneOffset: const Duration(hours: 5, minutes: 30))),
        'Wed, Dec 2, 2026, 9:00 PM – 10:30 PM UTC+5:30',
      );
    });

    test('same instant, different Circle zones', () {
      expect(_n(en.eventTime(startUtc, zoneOffset: const Duration(hours: 4))),
          'Wed, Dec 2, 2026, 7:30 PM UTC+4'); // Dubai
      expect(_n(en.eventTime(startUtc, zoneOffset: const Duration(hours: -5))),
          'Wed, Dec 2, 2026, 10:30 AM UTC−5'); // New York (winter)
      expect(_n(en.eventTime(startUtc, zoneOffset: Duration.zero)),
          'Wed, Dec 2, 2026, 3:30 PM UTC');
    });

    test('crossing midnight in the Circle zone shows the end date', () {
      final s = DateTime.utc(2026, 12, 2, 18, 0); // 23:30 at UTC+5:30
      final e = DateTime.utc(2026, 12, 2, 19, 0); // 00:30 next day
      expect(
        _n(en.eventTime(s, endUtc: e, zoneOffset: const Duration(hours: 5, minutes: 30))),
        'Wed, Dec 2, 2026, 11:30 PM – Thu, Dec 3, 2026, 12:30 AM UTC+5:30',
      );
    });

    test('without an offset the device zone is used and still labelled', () {
      final out = en.eventTime(startUtc);
      expect(out, matches(RegExp(r'UTC([+−]\d+(:\d\d)?)?$')));
    });

    test('utcLabel', () {
      expect(AppFormatters.utcLabel(Duration.zero), 'UTC');
      expect(AppFormatters.utcLabel(const Duration(hours: 5, minutes: 30)), 'UTC+5:30');
      expect(AppFormatters.utcLabel(const Duration(hours: -3, minutes: -30)), 'UTC−3:30');
    });
  });
}
