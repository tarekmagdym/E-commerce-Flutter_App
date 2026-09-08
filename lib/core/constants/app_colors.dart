import 'package:flutter/material.dart';

/// Centralized color palette for ShopEasy.
/// Based on the UI reference: dark navy splash/admin surfaces,
/// blue/indigo primary for CTAs, light neutral backgrounds elsewhere.
class AppColors {
  AppColors._();

  // Primary brand color (buttons, links, active states)
  static const Color primary = Color(0xFF4F6EF7);
  static const Color primaryDark = Color(0xFF3D56D6);

  // Splash / dark surfaces
  static const Color splashBackground = Color(0xFF13173B);
  static const Color splashIconBg = Color(0xFF1E2350);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFFAAB0C9);

  // Neutral / light UI
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFC7CBD6);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF8A8F9A);

  // Status
  static const Color success = Color(0xFF22C55E);
}