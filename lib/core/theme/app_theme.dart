import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primaryBlue,
        secondary: AppColor.primaryPink,
        surface: AppColor.lightSurface,
        error: AppColor.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.lightTextPrimary,
        outline: AppColor.lightBorder,
      ),
      textTheme:
          const TextTheme(
            displayLarge: AppTypography.displayLarge,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyLarge: AppTypography.bodyLarge,
            bodySmall: AppTypography.bodySmall,
            labelSmall: AppTypography.labelSmall,
          ).apply(
            bodyColor: AppColor.lightTextPrimary,
            displayColor: AppColor.lightTextPrimary,
          ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColor.primaryBlue,
        secondary: AppColor.primaryPink,
        surface: AppColor.darkSurface,
        error: AppColor.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.darkTextPrimary,
        outline: AppColor.darkBorder,
      ),
      textTheme:
          const TextTheme(
            displayLarge: AppTypography.displayLarge,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyLarge: AppTypography.bodyLarge,
            bodySmall: AppTypography.bodySmall,
            labelSmall: AppTypography.labelSmall,
          ).apply(
            bodyColor: AppColor.darkTextPrimary,
            displayColor: AppColor.darkTextPrimary,
          ),
    );
  }
}
