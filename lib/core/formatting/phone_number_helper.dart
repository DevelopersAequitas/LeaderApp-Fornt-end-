import 'dart:ui' show PlatformDispatcher;

import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Result of validating and normalizing an international phone number.
class PhoneValidationResult {
  const PhoneValidationResult({
    required this.isValid,
    this.e164,
    this.formattedNational,
    this.formattedInternational,
    this.countryIso,
    this.errorMessage,
  });

  final bool isValid;
  final String? e164;
  final String? formattedNational;
  final String? formattedInternational;
  final String? countryIso;
  final String? errorMessage;
}

/// Decomposed representation of an existing stored phone value so edit forms
/// can pre-select the matching country without silently mutating stored data.
class SplitStoredPhone {
  const SplitStoredPhone({
    required this.country,
    required this.nationalInput,
    required this.wasParsed,
  });

  final Country country;
  final String nationalInput;
  final bool wasParsed;
}

/// Centralized international phone number parsing, validation, formatting, and
/// E.164 normalization backed by `phone_numbers_parser`.
///
/// Design rules:
/// - Never forces India (`IN` / `+91`) as a universal default.
/// - Validates against the selected country's numbering plan (length + pattern).
/// - Normalizes to E.164 (`+<cc><nsn>`) matching the documented backend contract
///   (`POST /leader/auth/send-otp`, `verify-otp`, `PUT /leader/profile`, etc.).
/// - Preserves unparseable legacy stored strings on display instead of silently
///   mutating or dropping them.
class PhoneNumberHelper {
  PhoneNumberHelper._();

  /// Fallback country when the device locale carries no valid ISO region code.
  static const String fallbackCountryIso = 'US';

  /// Resolves the initial ISO 3166-1 alpha-2 country code from [localeCountryCode]
  /// (or the platform locale when omitted), falling back to [fallbackCountryIso]
  /// if unavailable or unsupported.
  static String resolveDefaultCountryIso({String? localeCountryCode}) {
    final candidate =
        (localeCountryCode ??
                PlatformDispatcher.instance.locale.countryCode ??
                '')
            .trim()
            .toUpperCase();
    if (candidate.length == 2 &&
        toIsoCode(candidate) != null &&
        Country.tryParse(candidate) != null) {
      return candidate;
    }
    return fallbackCountryIso;
  }

  /// Resolves a [Country] for [countryIso] or the platform locale.
  static Country resolveCountry({
    String? countryIso,
    String? localeCountryCode,
  }) {
    final code = (countryIso != null && countryIso.trim().isNotEmpty)
        ? countryIso.trim().toUpperCase()
        : resolveDefaultCountryIso(localeCountryCode: localeCountryCode);
    return Country.tryParse(code) ?? Country.parse(fallbackCountryIso);
  }

  /// Converts an alpha-2 ISO string (e.g. `'IN'`, `'US'`, `'GB'`) to [IsoCode].
  static IsoCode? toIsoCode(String? countryIso) {
    final code = countryIso?.trim().toUpperCase();
    if (code == null || code.isEmpty) return null;
    try {
      return IsoCode.values.byName(code);
    } catch (_) {
      return null;
    }
  }

  /// Resolves an ISO alpha-2 country code from a dial code like `'+44'` or `'1'`.
  /// Uses libphonenumber metadata's main country for shared calling codes.
  static String? isoCodeFromDialCode(String? dialCode) {
    if (dialCode == null) return null;
    final digits = dialCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    final list = countryCodeToIsoCode[digits];
    if (list == null || list.isEmpty) return null;
    return list.first.name;
  }

  /// Parses [input] using [countryIso] as the destination country when [input]
  /// does not start with an explicit international prefix (`+` or `00`).
  /// Returns `null` if [input] is empty or cannot be parsed.
  static PhoneNumber? tryParse(String input, {String? countryIso}) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final iso = toIsoCode(countryIso);
    try {
      if (trimmed.startsWith('+')) {
        return PhoneNumber.parse(trimmed);
      }
      if (iso != null) {
        return PhoneNumber.parse(trimmed, destinationCountry: iso);
      }
      return PhoneNumber.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  /// Validates [input] against [countryIso] (or the explicit `+` prefix if
  /// [allowInternationalOverride] is true and [input] starts with `+`).
  static PhoneValidationResult validate(
    String input, {
    required String countryIso,
    String? countryName,
    String? dialCode,
    bool allowInternationalOverride = true,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const PhoneValidationResult(
        isValid: false,
        errorMessage: 'Please enter a phone number.',
      );
    }

    final resolvedIso = toIsoCode(countryIso);
    if (resolvedIso == null) {
      return const PhoneValidationResult(
        isValid: false,
        errorMessage: 'Please select a valid country code.',
      );
    }

    final countryLabel = _countryDisplayLabel(
      countryIso: resolvedIso.name,
      countryName: countryName,
      dialCode: dialCode,
    );

    final hasExplicitPlus = trimmed.startsWith('+');
    PhoneNumber? parsed;
    try {
      if (hasExplicitPlus && allowInternationalOverride) {
        parsed = PhoneNumber.parse(trimmed);
      } else {
        // Strip a redundant leading +dialCode if the user pasted it while
        // keeping validation bound to the selected country.
        final normalizedInput = hasExplicitPlus
            ? trimmed
            : trimmed.replaceAll(RegExp(r'[^\d\s\-\(\)\.]'), '');
        if (normalizedInput.replaceAll(RegExp(r'[^\d]'), '').isEmpty) {
          return PhoneValidationResult(
            isValid: false,
            errorMessage:
                'Please enter a valid phone number for $countryLabel.',
          );
        }
        parsed = PhoneNumber.parse(
          normalizedInput,
          destinationCountry: resolvedIso,
        );
      }
    } catch (_) {
      return PhoneValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid phone number for $countryLabel.',
      );
    }

    // When the user did not supply a different international prefix, ensure the
    // parsed number belongs to the selected country (or same calling code).
    if (!hasExplicitPlus && parsed.isoCode != resolvedIso) {
      final selectedMeta = metadataByIsoCode[resolvedIso];
      if (selectedMeta == null ||
          parsed.countryCode != selectedMeta.countryCode) {
        return PhoneValidationResult(
          isValid: false,
          errorMessage: 'Please enter a valid phone number for $countryLabel.',
        );
      }
    }

    if (!parsed.isValid()) {
      return PhoneValidationResult(
        isValid: false,
        countryIso: parsed.isoCode.name,
        errorMessage: 'Please enter a valid phone number for $countryLabel.',
      );
    }

    final formattedNsn = parsed.formatNsn(format: NsnFormat.national);
    final formattedIntlNsn = parsed.formatNsn(format: NsnFormat.international);

    return PhoneValidationResult(
      isValid: true,
      e164: parsed.international,
      formattedNational: formattedNsn,
      formattedInternational: '+${parsed.countryCode} $formattedIntlNsn',
      countryIso: parsed.isoCode.name,
    );
  }

  /// Normalizes [input] to E.164 (e.g. `'+447911123456'`) when valid, else `null`.
  static String? toE164(String input, {required String countryIso}) {
    final res = validate(input, countryIso: countryIso);
    return res.isValid ? res.e164 : null;
  }

  /// Formats a phone string for human-readable international display, e.g.
  /// `'+1 415-555-2671'`, `'+44 7911 123456'`, `'+91 98765 43210'`.
  /// Returns [rawInput] trimmed unchanged when it cannot be parsed so stored
  /// values are never corrupted or hidden.
  static String formatInternational(
    String rawInput, {
    String? fallbackCountryIso,
  }) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';
    final parsed = tryParse(trimmed, countryIso: fallbackCountryIso);
    if (parsed == null || !parsed.isValid()) return trimmed;
    final formattedNsn = parsed.formatNsn(format: NsnFormat.international);
    return '+${parsed.countryCode} $formattedNsn';
  }

  /// Formats [rawInput] in national display format for [countryIso].
  static String formatNational(String rawInput, {required String countryIso}) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return '';
    final parsed = tryParse(trimmed, countryIso: countryIso);
    if (parsed == null) return trimmed;
    return parsed.formatNsn(format: NsnFormat.national);
  }

  /// Splits an existing stored phone number into its [Country] and national
  /// display input for edit forms without mutating the underlying record.
  static SplitStoredPhone splitStoredPhone(
    String? rawPhone, {
    String? fallbackCountryIso,
  }) {
    final fallbackCountry = resolveCountry(countryIso: fallbackCountryIso);
    final trimmed = rawPhone?.trim() ?? '';
    if (trimmed.isEmpty) {
      return SplitStoredPhone(
        country: fallbackCountry,
        nationalInput: '',
        wasParsed: false,
      );
    }

    final parsed = tryParse(
      trimmed,
      countryIso: trimmed.startsWith('+') ? null : fallbackCountry.countryCode,
    );
    if (parsed != null && parsed.isValid() && parsed.nsn.isNotEmpty) {
      final detectedCountry =
          Country.tryParse(parsed.isoCode.name) ?? fallbackCountry;
      final displayNational = parsed.formatNsn(format: NsnFormat.national);
      return SplitStoredPhone(
        country: detectedCountry,
        nationalInput: displayNational.isNotEmpty
            ? displayNational
            : parsed.nsn,
        wasParsed: true,
      );
    }

    return SplitStoredPhone(
      country: fallbackCountry,
      nationalInput: trimmed,
      wasParsed: false,
    );
  }

  /// Returns a country-appropriate national example placeholder (never hardcoded
  /// to India), e.g. `'(201) 555-0123'` for US or `'07400 123456'` for GB.
  static String exampleHint(String countryIso) {
    final iso = toIsoCode(countryIso);
    if (iso == null) return 'Phone number';
    final examples = metadataExamplesByIsoCode[iso];
    final raw = (examples?.mobile.isNotEmpty == true)
        ? examples!.mobile
        : (examples?.fixedLine ?? '');
    if (raw.isEmpty) return 'Phone number';
    try {
      final parsed = PhoneNumber(isoCode: iso, nsn: raw);
      final formatted = parsed.formatNsn(format: NsnFormat.national);
      return formatted.isNotEmpty ? formatted : raw;
    } catch (_) {
      return raw;
    }
  }

  static String _countryDisplayLabel({
    required String countryIso,
    String? countryName,
    String? dialCode,
  }) {
    final country = Country.tryParse(countryIso);
    final name = (countryName != null && countryName.trim().isNotEmpty)
        ? countryName.trim()
        : (country?.name ?? countryIso);
    final code = (dialCode != null && dialCode.trim().isNotEmpty)
        ? (dialCode.startsWith('+') ? dialCode.trim() : '+${dialCode.trim()}')
        : (country != null ? '+${country.phoneCode}' : '');
    return code.isNotEmpty ? '$name ($code)' : name;
  }
}
