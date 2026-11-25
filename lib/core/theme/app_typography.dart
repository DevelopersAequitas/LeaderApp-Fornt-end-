import 'package:flutter/material.dart';

/// Enterprise Typography Scale for Peers Global Leadership App.
///
/// Built on `LibreFranklin` (locally bundled weights 100–900) with
/// `FontFeature.tabularFigures()` for financial and operational metrics,
/// disciplined weights (w400–w600), and readable line heights.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'LibreFranklin';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ---------------------------------------------------------------------------
  // Display & Headline
  // ---------------------------------------------------------------------------
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
    fontFeatures: _tabular,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: -0.4,
    fontFeatures: _tabular,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.28,
    letterSpacing: -0.3,
  );

  // ---------------------------------------------------------------------------
  // Titles & Section Headers
  // ---------------------------------------------------------------------------
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: -0.1,
  );

  // ---------------------------------------------------------------------------
  // Body Copy
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ---------------------------------------------------------------------------
  // Labels & Captions (Minimum 11.5px — no unreadable micro-labels)
  // ---------------------------------------------------------------------------
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.05,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.05,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.05,
  );

  // ---------------------------------------------------------------------------
  // Tabular Numerical Metrics (KPIs, Financial Values, Counts)
  // ---------------------------------------------------------------------------
  static const TextStyle metricDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.5,
    fontFeatures: _tabular,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.18,
    letterSpacing: -0.35,
    fontFeatures: _tabular,
  );

  static const TextStyle metricMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.2,
    fontFeatures: _tabular,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
    fontFeatures: _tabular,
  );
}
