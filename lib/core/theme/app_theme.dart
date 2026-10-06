import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Centralized Material 3 Theme Configuration for MegaCess Mobile
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.mcBgApp,
      colorScheme: const ColorScheme.light(
        primary: AppColors.frond6,
        onPrimary: Colors.white,
        surface: AppColors.mcBgSurface,
        onSurface: AppColors.mcTextPrimary,
        error: AppColors.mcStatusDanger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mcForestDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.mcBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.mcBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mcBgSurface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        labelStyle: AppTypography.caption,
        hintStyle: AppTypography.caption.copyWith(color: AppColors.mcTextDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.frond6, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.mcStatusDanger, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.frond6,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: AppTypography.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.frond7,
          side: const BorderSide(color: AppColors.mcBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: AppTypography.buttonText,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.mcBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
