import 'package:flutter/material.dart';

/// Unified Enterprise Semantic Colour System for the Peers Global Leadership App.
///
/// Serves as the single source of truth across Light and Dark themes while
/// maintaining 100% backwards-compatible aliases for legacy screens.
class AppColor {
  AppColor._();

  // ---------------------------------------------------------------------------
  // 1. Core Brand Identity
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  /// Primary Enterprise Cobalt — primary actions, active indicators, links.
  static const Color primary = Color(0xFF1D4ED8);
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFEFF6FF);
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  /// Secondary Executive Rose — high-priority counters & brand accents only.
  static const Color secondary = Color(0xFFE11D48);
  static const Color primaryPink = Color(0xFFE11D48);
  static const Color secondaryContainer = Color(0xFFFFF1F2);
  static const Color onSecondaryContainer = Color(0xFF881337);

  /// Tertiary Slate Teal — balanced analytical & operational secondary tone.
  static const Color tertiary = Color(0xFF0F766E);
  static const Color tertiaryContainer = Color(0xFFF0FDFA);
  static const Color onTertiaryContainer = Color(0xFF134E4A);

  // ---------------------------------------------------------------------------
  // 2. Light Surface & Neutral Architecture (Linear / Stripe Slate Scale)
  // ---------------------------------------------------------------------------
  static const Color lightScaffoldBg = Color(0xFFF8FAFC);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color lightSurfaceMuted = Color(0xFFF8FAFC);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);

  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineStrong = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFEEF2F6);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // 3. Accessible Typography Hierarchy (WCAG AA Verified on #FFFFFF / #F8FAFC)
  // ---------------------------------------------------------------------------
  /// Slate 900 — 16.1:1 contrast on white.
  static const Color lightTextPrimary = Color(0xFF0F172A);

  /// Slate 600 — 7.5:1 contrast on white (passes WCAG AAA normal text).
  static const Color lightTextSecondary = Color(0xFF475569);

  /// Slate 500 — 4.6:1 contrast on white (passes WCAG AA metadata).
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF64748B);

  /// Slate 400 — disabled controls only.
  static const Color lightTextDisabled = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // 4. Dark Theme Surface & Typography Tokens
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1F2937);
  static const Color darkSurfaceSubtle = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF263143);
  static const Color darkDivider = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // 5. Semantic & Governance Status Palette (Always pair with Icon + Label)
  // ---------------------------------------------------------------------------
  /// Success / Completed / Active
  static const Color success = Color(0xFF047857);
  static const Color successDark = Color(0xFF065F46);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successLightBg = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successTextLight = Color(0xFFA7F3D0);

  /// Warning / Pending Approvals
  static const Color warning = Color(0xFFB45309);
  static const Color warningDark = Color(0xFF92400E);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningLightBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  /// Error / Critical Escalations
  static const Color error = Color(0xFFDC2626);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  /// Information / Scope Context
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);

  /// Explicit Operational Workflow Status Tokens
  static const Color critical = Color(0xFFDC2626);
  static const Color criticalBg = Color(0xFFFEF2F2);
  static const Color criticalBorder = Color(0xFFFECACA);

  static const Color pending = Color(0xFFB45309);
  static const Color pendingBg = Color(0xFFFFFBEB);
  static const Color pendingBorder = Color(0xFFFDE68A);

  static const Color completed = Color(0xFF047857);
  static const Color completedBg = Color(0xFFECFDF5);
  static const Color completedBorder = Color(0xFFA7F3D0);

  static const Color rejected = Color(0xFFBE123C);
  static const Color rejectedBg = Color(0xFFFFF1F2);
  static const Color rejectedBorder = Color(0xFFFECDD3);

  static const Color activeStatus = Color(0xFF047857);
  static const Color activeStatusBg = Color(0xFFECFDF5);
  static const Color activeStatusBorder = Color(0xFFA7F3D0);

  static const Color inactiveStatus = Color(0xFF475569);
  static const Color inactiveStatusBg = Color(0xFFF1F5F9);
  static const Color inactiveStatusBorder = Color(0xFFCBD5E1);

  // ---------------------------------------------------------------------------
  // 6. Data Visualization Series (Colour-blind safe, distinct from error/warn)
  // ---------------------------------------------------------------------------
  static const List<Color> dataSeries = [
    Color(0xFF1D4ED8), // Cobalt
    Color(0xFF0F766E), // Teal
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0284C7), // Sky
    Color(0xFF6D28D9), // Violet
    Color(0xFF334155), // Slate
  ];

  // ---------------------------------------------------------------------------
  // 7. Restrained Gradients & Legacy Compatibility Aliases
  // ---------------------------------------------------------------------------
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentBrandGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFFE11D48)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient tabBgGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleCardBorderGradient = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0B0F17), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color badgeBlueBg = primaryContainer;
  static const Color badgePinkBg = secondaryContainer;
  static const Color accentGreen = success;
  static const Color primaryGradientEnd = Color(0xFF1E40AF);
  static const Color surface = lightSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextTertiary;
  static const Color borderSubtle = lightBorder;
  static const Color background = lightScaffoldBg;
  static const Color backgroundSubtle = lightSurfaceSubtle;

  // Legacy AppColors compatibility bridges
  static const Color cardBg = lightSurface;
  static const Color text = lightTextPrimary;
  static const Color darkMidnight = darkBackground;
  static const Color secondaryBg = lightSurfaceSubtle;
  static const Color border = lightBorder;
  static const Color selectionBg = primaryContainer;
  static const Color disabled = lightTextDisabled;
  static const Color inactive = outlineStrong;
  static const Color dashedBorder = outlineStrong;
  static const Color chartPrimary = primaryBlue;
  static const Color chartSecondary = tertiary;
  static const Color chartLine = lightBorder;
  static const Color coinBg = Color(0xFFFFFBEB);
  static const Color coinColor = Color(0xFFD97706);
  static const Color attendanceBg = Color(0xFFF5F3FF);
  static const Color attendanceColor = Color(0xFF6D28D9);
  static const Color healthGreen = success;
  static const Color progressBg = lightSurfaceSubtle;
  static const Color leaderCardBg = primaryContainer;
  static const Color engagementGold = Color(0xFFB45309);
}

/// Unified alias so files importing either `AppColor` or `AppColors` share one palette.
typedef AppColors = AppColor;
