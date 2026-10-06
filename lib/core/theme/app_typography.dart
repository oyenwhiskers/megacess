import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Typography System for MegaCess Mobile
/// Utilizes Plus Jakarta Sans for high-contrast sunlight readability in plantation fields.
class AppTypography {
  // Hero KPI numbers (Dashboard metrics, totals)
  static TextStyle get heroNumber => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.mcTextPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.mcTextPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mcTextPrimary,
  );

  static TextStyle get bodyRegular => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mcTextPrimary,
    height: 1.4,
  );

  static TextStyle get bodyBold => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.mcTextPrimary,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.mcTextSecondary,
  );

  static TextStyle get captionMuted => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.mcTextSecondary,
  );

  static TextStyle get badgeLabel => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Design Token Semantic Aliases
  static TextStyle get headingLarge => titleLarge;
  static TextStyle get headingMedium => titleMedium;
  static TextStyle get headingH3 => titleLarge;
  static TextStyle get headingH4 => titleMedium;
  static TextStyle get bodyMedium => bodyRegular;
  static TextStyle get labelLarge => titleMedium;
  static TextStyle get bodySmall => caption;
  static TextStyle get quietLabel => captionMuted;
  static TextStyle get metaLabel => badgeLabel;
}
