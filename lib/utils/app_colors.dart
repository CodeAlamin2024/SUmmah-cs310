import 'package:flutter/material.dart';

/// Shared colour palette for SUmmah.
///
/// Values follow the "UI design (final colours)" page in our Figma file.
/// Every screen must use these constants instead of hard-coded colours.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1F3B33); // deep masjid green
  static const Color primaryDark = Color(0xFF132A23);
  static const Color primaryTint = Color(0xFFE6EEE9); // banners, selected nav pill
  static const Color accent = Color(0xFFC9A96E); // gold

  // Surfaces
  static const Color background = Color(0xFFF6F4EE); // cream page background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E0D8);

  // Text
  static const Color textPrimary = Color(0xFF1B1F1D);
  static const Color textSecondary = Color(0xFF6B716E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnPrimaryMuted = Color(0xB3FFFFFF); // 70 % white

  // States
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E6B4F);

  // Prayer times and announcements (S1–S3)
  static const Color nextPrayerBackground = Color(0xFFF7F1E6); // soft gold row
  static const Color divider = Color(0xFFEEECE5);
  static const Color textDisabled = Color(0xFFA3A8A5); // prayers that have passed
  static const Color imagePlaceholder = Color(0xFFDDE6E1);
  static const Color motifOnPrimary = Color(0x4DC9A96E); // 30 % gold

  /// Dark scrim shown behind confirmation dialogs (90 % of [primaryDark]).
  static const Color dialogBarrier = Color(0xE6132A23);
  static const Color dividerOnPrimary = Color(0x33FFFFFF);
}
