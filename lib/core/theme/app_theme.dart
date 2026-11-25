import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_page_route.dart';
import 'app_color.dart';
import 'app_motion.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Centralized Material 3 Theme configuration for Light and Dark modes.
class AppTheme {
  AppTheme._();

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SmoothPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: SmoothPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: SmoothPageTransitionsBuilder(),
    },
  );

  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: primaryText),
      displayMedium: AppTypography.displayMedium.copyWith(color: primaryText),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: primaryText),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: primaryText),
      titleLarge: AppTypography.titleLarge.copyWith(color: primaryText),
      titleMedium: AppTypography.titleMedium.copyWith(color: primaryText),
      titleSmall: AppTypography.titleSmall.copyWith(color: primaryText),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primaryText),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: primaryText),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondaryText),
      labelLarge: AppTypography.labelLarge.copyWith(color: primaryText),
      labelMedium: AppTypography.labelMedium.copyWith(color: secondaryText),
      labelSmall: AppTypography.labelSmall.copyWith(color: secondaryText),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColor.lightScaffoldBg,
      pageTransitionsTheme: _pageTransitions,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: AppColor.primary.withValues(alpha: 0.05),
      splashColor: AppColor.primary.withValues(alpha: 0.07),
      dividerColor: AppColor.divider,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        onPrimary: AppColor.white,
        primaryContainer: AppColor.primaryContainer,
        onPrimaryContainer: AppColor.onPrimaryContainer,
        secondary: AppColor.secondary,
        onSecondary: AppColor.white,
        secondaryContainer: AppColor.secondaryContainer,
        onSecondaryContainer: AppColor.onSecondaryContainer,
        tertiary: AppColor.tertiary,
        onTertiary: AppColor.white,
        tertiaryContainer: AppColor.tertiaryContainer,
        onTertiaryContainer: AppColor.onTertiaryContainer,
        surface: AppColor.lightSurface,
        onSurface: AppColor.lightTextPrimary,
        surfaceContainerLowest: AppColor.surfaceContainerLowest,
        surfaceContainerLow: AppColor.surfaceContainerLow,
        surfaceContainer: AppColor.surfaceContainer,
        surfaceContainerHigh: AppColor.surfaceContainerHigh,
        onSurfaceVariant: AppColor.lightTextSecondary,
        outline: AppColor.outline,
        outlineVariant: AppColor.divider,
        error: AppColor.error,
        onError: AppColor.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.lightSurface,
        foregroundColor: AppColor.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColor.lightSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: AppColor.outline,
        ),
        iconTheme: IconThemeData(color: AppColor.lightTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColor.lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColor.lightSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColor.outline, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColor.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          elevation: 0,
          animationDuration: AppMotion.press,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.lightTextPrimary,
          elevation: 0,
          animationDuration: AppMotion.press,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge,
          side: const BorderSide(color: AppColor.outlineStrong, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.lightSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColor.lightTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColor.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColor.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColor.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColor.error),
        ),
      ),
      textTheme: _buildTextTheme(
        AppColor.lightTextPrimary,
        AppColor.lightTextSecondary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColor.darkBackground,
      pageTransitionsTheme: _pageTransitions,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: AppColor.darkDivider,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        onPrimary: AppColor.white,
        primaryContainer: Color(0xFF1E3A8A),
        onPrimaryContainer: Color(0xFFDBEAFE),
        secondary: AppColor.secondary,
        onSecondary: AppColor.white,
        tertiary: Color(0xFF14B8A6),
        surface: AppColor.darkSurface,
        onSurface: AppColor.darkTextPrimary,
        onSurfaceVariant: AppColor.darkTextSecondary,
        outline: AppColor.darkBorder,
        outlineVariant: AppColor.darkDivider,
        error: Color(0xFFF87171),
        onError: AppColor.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.darkSurface,
        foregroundColor: AppColor.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColor.darkSurface,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: AppColor.darkBorder,
        ),
        iconTheme: IconThemeData(color: AppColor.darkTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColor.darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColor.darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColor.darkBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColor.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),
      textTheme: _buildTextTheme(
        AppColor.darkTextPrimary,
        AppColor.darkTextSecondary,
      ),
    );
  }
}
