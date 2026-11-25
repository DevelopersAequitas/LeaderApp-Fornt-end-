import 'package:flutter/widgets.dart';

/// 4pt / 8pt Grid Spacing & Shape Tokens for Peers Global Leadership App.
class AppSpacing {
  AppSpacing._();

  // Base 4pt/8pt Scale (preserving existing token names)
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s6 = 6.0;
  static const double sm = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Semantic Layout Tokens
  static const double screenMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 12.0;
  static const double sectionGap = 20.0;
  static const double componentGap = 12.0;
  static const double listItemGap = 8.0;
  static const double formFieldGap = 16.0;
  static const double navBarHeight = 64.0;
  static const double minTouchTarget = 44.0;

  // Standard EdgeInsets Presets
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: screenMargin);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardCompactInsets = EdgeInsets.all(cardPaddingCompact);

  // Refined Enterprise Corner Radii
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusSheet = 20.0;
  static const double radiusPill = 999.0;
}
