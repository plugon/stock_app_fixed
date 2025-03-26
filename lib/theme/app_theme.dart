import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// 앱 전체에서 사용되는 테마 정의
class AppTheme {
  // 라이트 테마 정의
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.dividerLight,
    shadowColor: AppColors.shadowLight,
    textTheme: TextTheme(
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimaryLight),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryLight),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryLight),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryLight),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryLight),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.upColor,
      error: AppColors.downColor,
      surface: AppColors.cardLight,
      background: AppColors.backgroundLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonLight,
        foregroundColor: Colors.white,
      ),
    ),
  );

  // 다크 테마 정의
  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    shadowColor: AppColors.shadowDark,
    textTheme: TextTheme(
      headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimaryDark),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimaryDark),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryDark),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
      titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryDark),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.upColor,
      error: AppColors.downColor,
      surface: AppColors.cardDark,
      background: AppColors.backgroundDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonDark,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
