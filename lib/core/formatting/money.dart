/// A monetary amount with its ISO 4217 currency code.
///
/// Amounts from different currencies must never be added or charted together
/// without an explicit, backend-provided conversion — [plus] enforces this.
///
/// Today most API values arrive as pre-formatted strings such as `"₹72,000"`;
/// [Money.tryParseFormatted] is a *read-only adapter* for those legacy strings
/// so screens can migrate gradually. It returns `null` (never a fabricated 0)
/// when the text cannot be understood.
class Money {
  const Money(this.amount, this.currencyCode);

  /// The numeric amount in major units (e.g. rupees, dollars).
  final double amount;

  /// ISO 4217 code, e.g. `INR`, `USD`, `AED`.
  final String currencyCode;

  bool get isZero => amount == 0;

  Money plus(Money other) {
    if (other.currencyCode != currencyCode) {
      throw ArgumentError(
        'Cannot add $currencyCode and ${other.currencyCode} without a '
        'backend-provided conversion rate.',
      );
    }
    return Money(amount + other.amount, currencyCode);
  }

  static const Map<String, String> _symbolToCode = {
    '₹': 'INR',
    r'$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    'AED': 'AED',
    'د.إ': 'AED',
  };

  // Indian and western abbreviations used by the existing UI strings.
  static const Map<String, double> _suffixMultiplier = {
    'k': 1e3,
    'l': 1e5,
    'lakh': 1e5,
    'lac': 1e5,
    'cr': 1e7,
    'crore': 1e7,
    'm': 1e6,
    'mn': 1e6,
    'b': 1e9,
    'bn': 1e9,
  };

  /// Parses legacy formatted strings like `₹72,000`, `₹13L`, `₹500.05Cr`,
  /// `$1.2M`, `AED 4,500`. Returns `null` when there is no recognisable
  /// currency or number (so callers can show "unavailable").
  static Money? tryParseFormatted(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;

    String? code;
    var rest = text;
    for (final entry in _symbolToCode.entries) {
      if (rest.contains(entry.key)) {
        code = entry.value;
        rest = rest.replaceAll(entry.key, '');
        break;
      }
    }
    if (code == null) return null;

    rest = rest.replaceAll(',', '').replaceAll(RegExp(r'\s+'), '');
    final match = RegExp(r'^(-?\d+(?:\.\d+)?)([a-zA-Z]*)$').firstMatch(rest);
    if (match == null) return null;

    final number = double.tryParse(match.group(1)!);
    if (number == null) return null;
    final suffix = match.group(2)!.toLowerCase();
    if (suffix.isEmpty) return Money(number, code);
    final mult = _suffixMultiplier[suffix];
    if (mult == null) return null;
    return Money(number * mult, code);
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.amount == amount &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(amount, currencyCode);

  @override
  String toString() => 'Money($amount $currencyCode)';
}
