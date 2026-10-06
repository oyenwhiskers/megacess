import 'package:flutter/material.dart';

/// MegaCess Brand & Design System Color Tokens
/// Aligned with the React / Mantine v7 Frond Green Design System
class AppColors {
  // Brand Forest Green (App Bar, Primary Top Banners, Splash)
  static const Color mcForestDark = Color(0xFF0B3B24);
  static const Color mcForestGreen = Color(0xFF0B3B24); // Alias

  // The Frond Green Scale (Oil Palm Canopy Palette)
  static const Color frond0 = Color(0xFFF3F8F1); // Highlighted card surface, badge background
  static const Color frond1 = Color(0xFFE2EEDD); // Card border hover, filter chips
  static const Color frond2 = Color(0xFFC6DFBC); // Chart gridlines, subtle track fills
  static const Color frond3 = Color(0xFFA3CC92); // Secondary chart bars, accent lines
  static const Color frond4 = Color(0xFF7FB86C); // Chart bar fill (light end)
  static const Color frond5 = Color(0xFF5CA24A); // Interactive links, active icon state
  static const Color frond6 = Color(0xFF47883A); // Primary Brand Green - buttons, active nav
  static const Color frond7 = Color(0xFF386C2E); // Button pressed, headings-on-white
  static const Color frond8 = Color(0xFF2A5223); // Dark badge background, selected nav
  static const Color frond9 = Color(0xFF1C3818); // Header boundary, high-emphasis text

  // Numeric Scale Aliases
  static const Color frond50 = frond0;
  static const Color frond100 = frond1;
  static const Color frond200 = frond2;
  static const Color frond300 = frond3;
  static const Color frond400 = frond4;
  static const Color frond500 = frond5;
  static const Color frond600 = frond6;
  static const Color frond700 = frond7;
  static const Color frond800 = frond8;
  static const Color frond900 = frond9;

  // Neutral Backgrounds & Surfaces
  static const Color mcBgApp = Color(0xFFF7F9F6); // Scaffold background (warm frond tint)
  static const Color mcBgSurface = Color(0xFFFFFFFF); // Card, dialog, bottom sheet surface
  static const Color mcBorder = Color(0xFFE3E8E0); // 1px card border, list dividers

  // Typography Neutrals
  static const Color mcTextPrimary = Color(0xFF1B2420); // Headings, values, high-contrast body
  static const Color mcTextSecondary = Color(0xFF5B6B60); // Captions, labels, timestamps
  static const Color mcTextDisabled = Color(0xFF9AA79F); // Placeholders, inactive state
  static const Color mcTextMuted = mcTextSecondary; // Alias
  static const Color textPrimary = mcTextPrimary; // Alias
  static const Color textSecondary = mcTextSecondary; // Alias
  static const Color textDisabled = mcTextDisabled; // Alias
  static const Color textMuted = mcTextMuted; // Alias

  // Semantic Status Colors
  static const Color mcStatusSuccess = Color(0xFF47883A); // Completed, Approved, Checked-in
  static const Color mcStatusPending = Color(0xFFC87F1F); // Pending Audit, Awaiting Sign-off (Ochre)
  static const Color mcStatusProgress = Color(0xFF3E6FA8); // In Progress (Slate Blue)
  static const Color mcStatusDanger = Color(0xFFC1443B); // Absent, Rejected, Critical (Brick Red)
  static const Color mcStatusRed = mcStatusDanger; // Alias
  static const Color mcStatusOrange = mcStatusPending; // Alias
  static const Color mcStatusBlue = mcStatusProgress; // Alias
  static const Color mcStatusGreen = mcStatusSuccess; // Alias

  // Status Tint Backgrounds (for soft badge/pill surfaces)
  static const Color mcStatusSuccessBg = Color(0xFFEBF5EA);
  static const Color mcStatusPendingBg = Color(0xFFFDF4E7);
  static const Color mcStatusProgressBg = Color(0xFFEEF4FA);
  static const Color mcStatusDangerBg = Color(0xFFFCEBEA);

  // Status Aliases
  static const Color statusCompletedText = mcStatusSuccess;
  static const Color statusCompletedBg = mcStatusSuccessBg;
  static const Color statusCompletedBorder = frond2;
  static const Color statusPendingText = mcStatusPending;
  static const Color statusPendingBg = mcStatusPendingBg;
  static const Color statusProgressText = mcStatusProgress;
  static const Color statusProgressBg = mcStatusProgressBg;
  static const Color statusRejectedText = mcStatusDanger;
  static const Color statusRejectedBg = mcStatusDangerBg;
  static const Color statusRejectedBorder = Color(0xFFF0B8B5);
}
