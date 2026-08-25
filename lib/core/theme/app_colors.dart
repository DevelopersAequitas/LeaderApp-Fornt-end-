import 'package:flutter/material.dart';

/// Defines the color palette used across the Leader App.
abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF102640);       // Dark navy
  static const Color text = Color(0xFF1A2535);          // Dark primary text
  static const Color textSecondary = Color(0xFF8B9CB4);   // Slate gray subtitle/text
  static const Color darkMidnight = Color(0xFF07111D);   // Midnight blue (Splash gradient)

  // Backgrounds & Borders
  static const Color background = Color(0xFFF9FAFC);     // Main body background
  static const Color cardBg = Colors.white;              // Standard white card background
  static const Color secondaryBg = Color(0xFFF3F5F9);    // Input, Segment control, badge bg
  static const Color border = Color(0xFFEDEFF3);         // Card/Divider borders
  static const Color selectionBg = Color(0xFFE8EEF8);    // Highlighted/Selected list tile bg

  // Status & Semantic Colors
  // Green (Success / Active)
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);

  // Orange (Warning / Rating / Inactive Tab)
  static const Color warning = Color(0xFFC7923E);
  static const Color warningBg = Color(0xFFFFF3E0);

  // Red (Danger / At Risk / Error)
  static const Color danger = Color(0xFFC62828);
  static const Color dangerBg = Color(0xFFFFEBEE);
  static const Color dangerBorder = Color(0xFFFFE3E3);

  // Blue (Info / Neutral Highlights)
  static const Color info = Color(0xFF1A73E8);
  static const Color infoBg = Color(0xFFE8F0FE);

  // Analytics & Custom Charts
  static const Color chartPrimary = Color(0xFF1E3A60);
  static const Color chartSecondary = Color(0xFF00796B);
  static const Color chartLine = Color(0xFFE1DDF6);

  // Miscellaneous
  static const Color disabled = Color(0xFFBDC7D5);
  static const Color inactive = Color(0xFFE0E0E0);
  static const Color dashedBorder = Color(0xFFDDE3ED);
  static const Color successTextLight = Color(0xFFBCE7D6);
  static const Color coinBg = Color(0xFFFEFDE7);
  static const Color coinColor = Color(0xFFFBC02D);
  static const Color attendanceBg = Color(0xFFF3E5F5);
  static const Color attendanceColor = Color(0xFF8E24AA);
  static const Color warningBorder = Color(0xFFFFEBD5);
  static const Color successBorder = Color(0xFFDCFCE7);
  static const Color infoBorder = Color(0xFF64B5F6);

  // Extended Semantic Colors
  static const Color successDark = Color(0xFF0F7A50);        // Dark green text/icons
  static const Color successLightBg = Color(0xFFE2F4EC);     // Lighter green badge bg
  static const Color warningDark = Color(0xFFD97706);        // Dark amber text/icons
  static const Color warningLightBg = Color(0xFFFFF4EB);     // Light orange event bg
  static const Color healthGreen = Color(0xFF00C853);        // Bright green health indicator
  static const Color progressBg = Color(0xFFE8ECEF);         // Progress bar track bg
  static const Color leaderCardBg = Color(0xFFEDF2FA);       // Leader card/chip bg
  static const Color engagementGold = Color(0xFFB58E3D);     // Engagement/gold metric
}
