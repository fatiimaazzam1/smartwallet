import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Main SmartWallet brand color.
  static const Color primary = Color(0xFF0D1B2A);

  // Accent color used for links, success states, and small highlights.
  static const Color accent = Color(0xFF22C55E);

  // Main screen background.
  static const Color background = Color(0xFFF1F5F9);

  // White surfaces such as text fields and cards.
  static const Color surface = Color(0xFFFFFFFF);

  // Main headings and important text.
  static const Color textPrimary = Color(0xFF0F172A);

  // Subtitles, hints, and supporting text.
  static const Color textSecondary = Color(0xFF64748B);

  // Borders around text fields and cards.
  static const Color border = Color(0xFFD8E0EA);

  // Error messages and invalid fields.
  static const Color error = Color(0xFFDC2626);

  // Disabled button background.
  static const Color disabled = Color(0xFF94A3B8);

  // Light green background for success messages.
  static const Color successBackground = Color(0xFFDCFCE7);
}
