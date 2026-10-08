import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // Base
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Brand Colors
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color primaryPink = Color(0xFFE11D48);

  // Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFFE11D48)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Subtle screen background gradient (top → bottom, barely visible)
  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Tab screen background gradient
  static const LinearGradient tabBgGradient = LinearGradient(
    colors: [
      Color(0xFFF9FAFB), // Clean premium top
      Color(0xFFEFF6FF), // Soft executive ice blue
      Color(0xFFFDF2F8), // Soft subtle rose hint
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card border gradient:
  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [
      Color(0xFF1D4ED8), // Royal Brand Blue
      Color(0xFFE11D48), // Vivid Rose/Pink
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle/soft card border gradient:
  static const LinearGradient subtleCardBorderGradient = LinearGradient(
    colors: [Color(0x801D4ED8), Color(0x80E11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF12141A), Color(0xFF181C27)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light Palette
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);
  static const Color lightSurfaceMuted = Color(0xFFF8FAFC);
  static const Color lightScaffoldBg = Color(0xFFF6F9FD);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF334155);
  static const Color lightTextDisabled = Color(0xFF94A3B8);
  static const Color badgeBlueBg = Color(0xFFEFF6FF);
  static const Color badgePinkBg = Color(0xFFFFF1F2);

  // Dark Palette
  static const Color darkBackground = Color(0xFF12141A);
  static const Color darkSurface = Color(0xFF1E222D);
  static const Color darkSurfaceSubtle = Color(0xFF242938);
  static const Color darkBorder = Color(0xFF2A2F3D);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color black = Color(0xFF000000);

  static const Color lightTextTertiary = lightTextDisabled;
  static const Color darkTextTertiary = darkTextDisabled;
  static const Color accentGreen = success;
  static const Color primary = primaryBlue;
  static const Color primaryGradientEnd = primaryPink;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextDisabled;
  static const Color borderSubtle = lightBorder;
  static const Color background = lightScaffoldBg;
  static const Color backgroundSubtle = lightSurfaceSubtle;

  // Compatibility Bridges for existing AppColors usage
  static const Color cardBg = lightSurface;
  static const Color text = lightTextPrimary;
  static const Color darkMidnight = darkBackground;
  static const Color secondaryBg = lightSurfaceSubtle;
  static const Color border = lightBorder;
  static const Color selectionBg = badgeBlueBg;
  static const Color danger = error;
  static const Color dangerBg = badgePinkBg;
  static const Color dangerBorder = Color(0xFFFECDD3);
  static const Color info = primaryBlue;
  static const Color infoBg = badgeBlueBg;
  static const Color infoBorder = Color(0xFF93C5FD);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successDark = Color(0xFF047857);
  static const Color successLightBg = Color(0xFFECFDF5);
  static const Color successTextLight = Color(0xFFA7F3D0);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningLightBg = Color(0xFFFFFBEB);
  static const Color disabled = lightTextDisabled;
  static const Color inactive = lightBorder;
  static const Color dashedBorder = lightBorder;
  static const Color chartPrimary = primaryBlue;
  static const Color chartSecondary = success;
  static const Color chartLine = lightBorder;
  static const Color coinBg = Color(0xFFFEF3C7);
  static const Color coinColor = warning;
  static const Color attendanceBg = Color(0xFFF3E8FF);
  static const Color attendanceColor = Color(0xFF9333EA);
  static const Color healthGreen = success;
  static const Color progressBg = lightSurfaceSubtle;
  static const Color leaderCardBg = badgeBlueBg;
  static const Color engagementGold = warning;
}

/// Backwards compatibility alias for AppColors.
typedef AppColors = AppColor;
