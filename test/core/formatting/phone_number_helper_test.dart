import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/formatting/phone_number_helper.dart';
import 'package:leaderapp/features/login/view/widgets/login_input_field.dart';

void main() {
  group('PhoneNumberHelper — country defaults', () {
    test(
      'resolves locale country code and does not force India universally',
      () {
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: 'GB'),
          'GB',
        );
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: 'US'),
          'US',
        );
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: 'IN'),
          'IN',
        );
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: 'AE'),
          'AE',
        );
        // Empty / invalid locale falls back to neutral US, not India.
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: ''),
          PhoneNumberHelper.fallbackCountryIso,
        );
        expect(
          PhoneNumberHelper.resolveDefaultCountryIso(localeCountryCode: 'ZZ'),
          PhoneNumberHelper.fallbackCountryIso,
        );
      },
    );

    test('exampleHint is country-specific rather than hardcoded India', () {
      final usHint = PhoneNumberHelper.exampleHint('US');
      final gbHint = PhoneNumberHelper.exampleHint('GB');
      final inHint = PhoneNumberHelper.exampleHint('IN');
      expect(usHint, isNot(contains('+91')));
      expect(gbHint, isNot(contains('+91')));
      expect(usHint, isNot(equals(gbHint)));
      expect(inHint, isNotEmpty);
    });
  });

  group('PhoneNumberHelper — validation & normalization', () {
    test('Indian numbers validate, format, and normalize to E.164', () {
      final res = PhoneNumberHelper.validate('98765 43210', countryIso: 'IN');
      expect(res.isValid, isTrue);
      expect(res.e164, '+919876543210');
      expect(res.countryIso, 'IN');
      expect(res.formattedInternational, startsWith('+91 '));
      expect(res.errorMessage, isNull);

      final intl = PhoneNumberHelper.validate(
        '+919876543210',
        countryIso: 'IN',
      );
      expect(intl.isValid, isTrue);
      expect(intl.e164, '+919876543210');
    });

    test('US numbers validate, format, and normalize to E.164', () {
      final res = PhoneNumberHelper.validate(
        '(415) 555-2671',
        countryIso: 'US',
      );
      expect(res.isValid, isTrue);
      expect(res.e164, '+14155552671');
      expect(res.countryIso, 'US');
      expect(res.formattedInternational, startsWith('+1 '));
    });

    test(
      'UK numbers (including trunk 0 and >10 digits) validate and normalize',
      () {
        final withTrunk = PhoneNumberHelper.validate(
          '07400 123456',
          countryIso: 'GB',
        );
        expect(withTrunk.isValid, isTrue);
        expect(withTrunk.e164, '+447400123456');
        expect(withTrunk.countryIso, 'GB');

        final withoutTrunk = PhoneNumberHelper.validate(
          '7400123456',
          countryIso: 'GB',
        );
        expect(withoutTrunk.isValid, isTrue);
        expect(withoutTrunk.e164, '+447400123456');
      },
    );

    test(
      'country-code change changes validation outcome for the same digits',
      () {
        // Valid UK mobile with trunk 0 (11 digits) is invalid as a US number.
        expect(
          PhoneNumberHelper.validate('07400123456', countryIso: 'GB').isValid,
          isTrue,
        );
        expect(
          PhoneNumberHelper.validate('07400123456', countryIso: 'US').isValid,
          isFalse,
        );

        // Valid IN mobile 9876543210 is invalid as a US NANP number (987 unassigned).
        expect(
          PhoneNumberHelper.validate('9876543210', countryIso: 'IN').isValid,
          isTrue,
        );
        expect(
          PhoneNumberHelper.validate('9876543210', countryIso: 'US').isValid,
          isFalse,
        );
      },
    );

    test('rejects invalid numbers with clear country-aware message', () {
      final tooShort = PhoneNumberHelper.validate('12345', countryIso: 'GB');
      expect(tooShort.isValid, isFalse);
      expect(tooShort.e164, isNull);
      expect(tooShort.errorMessage, contains('United Kingdom'));
      expect(tooShort.errorMessage, contains('+44'));

      final badPrefix = PhoneNumberHelper.validate(
        '5551234567',
        countryIso: 'IN',
      );
      expect(badPrefix.isValid, isFalse);
      expect(badPrefix.errorMessage, contains('India'));

      final lettersOnly = PhoneNumberHelper.validate(
        'abcdef',
        countryIso: 'US',
      );
      expect(lettersOnly.isValid, isFalse);
      expect(lettersOnly.errorMessage, contains('United States'));
    });

    test('rejects empty input with clear message', () {
      final empty = PhoneNumberHelper.validate('   ', countryIso: 'US');
      expect(empty.isValid, isFalse);
      expect(empty.errorMessage, 'Please enter a phone number.');
    });

    test(
      'formats international numbers and preserves unparseable stored strings',
      () {
        expect(
          PhoneNumberHelper.formatInternational('+447400123456'),
          '+44 7400 123456',
        );
        expect(
          PhoneNumberHelper.formatInternational('+14155552671'),
          '+1 415-555-2671',
        );
        // Legacy unparseable value is preserved verbatim without silent mutation.
        expect(
          PhoneNumberHelper.formatInternational('ext-42-desk'),
          'ext-42-desk',
        );
      },
    );

    test(
      'splitStoredPhone detects country from E.164 and preserves legacy raw values',
      () {
        final uk = PhoneNumberHelper.splitStoredPhone('+447400123456');
        expect(uk.wasParsed, isTrue);
        expect(uk.country.countryCode, 'GB');
        expect(uk.nationalInput, isNotEmpty);

        final indian = PhoneNumberHelper.splitStoredPhone('+91 98765 43210');
        expect(indian.wasParsed, isTrue);
        expect(indian.country.countryCode, 'IN');

        final legacy = PhoneNumberHelper.splitStoredPhone(
          'office-desk-101',
          fallbackCountryIso: 'US',
        );
        expect(legacy.wasParsed, isFalse);
        expect(legacy.country.countryCode, 'US');
        expect(legacy.nationalInput, 'office-desk-101');
      },
    );
  });

  group('LoginInputField — international input (no 10-digit cap)', () {
    testWidgets('accepts >10-character UK number with leading 0 and spaces', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String latest = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginInputField(
              controller: controller,
              isWhatsapp: true,
              dialCode: '+44',
              flag: '🇬🇧',
              countryCode: 'GB',
              onChanged: (v) => latest = v,
              onCountryTap: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '07911 123456');
      expect(controller.text, '07911 123456');
      expect(latest, '07911 123456');
    });
  });
}
