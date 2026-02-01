import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryLight = Color(0xFF6B4EE6);
  static const Color primaryDark = Color(0xFF9B7EFF);

  // Secondary Colors
  static const Color secondaryLight = Color(0xFFE6A94E);
  static const Color secondaryDark = Color(0xFFFFD07E);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F6FF);
  static const Color backgroundDark = Color(0xFF1A1625);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2640);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF362F4A);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A1625);
  static const Color textPrimaryDark = Color(0xFFF8F6FF);
  static const Color textSecondaryLight = Color(0xFF6B6880);
  static const Color textSecondaryDark = Color(0xFFB0A8C4);

  // Accent Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Fortune Colors
  static const Color fortuneLove = Color(0xFFE91E63);
  static const Color fortuneMoney = Color(0xFF4CAF50);
  static const Color fortuneCareer = Color(0xFF2196F3);
  static const Color fortuneGeneral = Color(0xFF9C27B0);

  // Zodiac Colors
  static const Map<String, Color> zodiacColors = {
    'aries': Color(0xFFE53935),
    'taurus': Color(0xFF8BC34A),
    'gemini': Color(0xFFFFEB3B),
    'cancer': Color(0xFF90CAF9),
    'leo': Color(0xFFFF9800),
    'virgo': Color(0xFF795548),
    'libra': Color(0xFFE91E63),
    'scorpio': Color(0xFF6D4C41),
    'sagittarius': Color(0xFF9C27B0),
    'capricorn': Color(0xFF607D8B),
    'aquarius': Color(0xFF00BCD4),
    'pisces': Color(0xFF3F51B5),
  };
}
