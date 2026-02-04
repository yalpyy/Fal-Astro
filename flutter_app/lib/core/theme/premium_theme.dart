import 'package:flutter/material.dart';

/// Premium Mystical Design System
///
/// A calm, premium, monetizable design system for astrology apps.
/// Dark theme with depth, glow, and emotional engagement.

class PremiumColors {
  PremiumColors._();

  // ═══════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════════════════════════════

  /// Primary dark background - Deep cosmic indigo
  static const Color backgroundDark = Color(0xFF0A0A14);

  /// Secondary background - Slightly lighter for depth
  static const Color backgroundSecondary = Color(0xFF0D0D1A);

  /// Tertiary background - Card surfaces
  static const Color backgroundTertiary = Color(0xFF12121F);

  /// Card background with glassmorphism effect
  static const Color cardBackground = Color(0xFF1A1A2E);

  /// Elevated card background
  static const Color cardElevated = Color(0xFF1F1F35);

  /// Ad container background (muted, respectful)
  static const Color adContainerBackground = Color(0xFF14141F);

  // ═══════════════════════════════════════════════════════════════════
  // PRIMARY ACCENT - Mystical Purple
  // ═══════════════════════════════════════════════════════════════════

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFF9F67FF);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);
  static const Color primaryPurpleGlow = Color(0x407C3AED);

  // ═══════════════════════════════════════════════════════════════════
  // PREMIUM ACCENT - Warm Gold
  // ═══════════════════════════════════════════════════════════════════

  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGoldLight = Color(0xFFFFE44D);
  static const Color premiumGoldDark = Color(0xFFD4A500);
  static const Color premiumGoldMuted = Color(0xFFBFA04D);
  static const Color premiumGoldGlow = Color(0x40FFD700);

  // ═══════════════════════════════════════════════════════════════════
  // ENERGY/SCORE COLORS
  // ═══════════════════════════════════════════════════════════════════

  /// Love/Romance - Soft rose
  static const Color energyLove = Color(0xFFFF6B9D);
  static const Color energyLoveGlow = Color(0x40FF6B9D);

  /// Career/Work - Calm blue
  static const Color energyCareer = Color(0xFF4A9DFF);
  static const Color energyCareerGlow = Color(0x404A9DFF);

  /// Money/Finance - Fresh green
  static const Color energyMoney = Color(0xFF4ADE80);
  static const Color energyMoneyGlow = Color(0x404ADE80);

  /// Health/Wellness - Warm orange
  static const Color energyHealth = Color(0xFFFF9F43);
  static const Color energyHealthGlow = Color(0x40FF9F43);

  /// Spiritual/Soul - Mystical teal
  static const Color energySpiritual = Color(0xFF5EEAD4);
  static const Color energySpiritualGlow = Color(0x405EEAD4);

  // ═══════════════════════════════════════════════════════════════════
  // ACCENT COLORS
  // ═══════════════════════════════════════════════════════════════════

  /// Cyan accent for highlights
  static const Color accentCyan = Color(0xFF5EEAD4);
  static const Color accentCyanGlow = Color(0x405EEAD4);

  /// Surface colors
  static const Color surfaceLight = Color(0xFF252538);
  static const Color surfaceMedium = Color(0xFF1E1E30);

  // ═══════════════════════════════════════════════════════════════════
  // TEXT HIERARCHY
  // ═══════════════════════════════════════════════════════════════════

  /// Primary text - High emphasis
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Secondary text - Medium emphasis
  static const Color textSecondary = Color(0xFFB8B8C7);

  /// Tertiary text - Low emphasis / hints
  static const Color textTertiary = Color(0xFF6E6E82);

  /// Disabled text
  static const Color textDisabled = Color(0xFF4A4A5C);

  // ═══════════════════════════════════════════════════════════════════
  // UI ELEMENTS
  // ═══════════════════════════════════════════════════════════════════

  /// Subtle borders
  static const Color borderSubtle = Color(0xFF2A2A3E);

  /// Divider color
  static const Color divider = Color(0xFF1F1F35);

  /// Success state
  static const Color success = Color(0xFF4ADE80);

  /// Warning state
  static const Color warning = Color(0xFFFFB020);

  /// Error state
  static const Color error = Color(0xFFFF6B6B);

  // ═══════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════

  /// Main app background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0D1A),
      Color(0xFF0A0A14),
      Color(0xFF08080F),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Premium card gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF5B21B6),
    ],
  );

  /// Gold premium gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE44D),
      Color(0xFFFFD700),
      Color(0xFFD4A500),
    ],
  );
}

/// Premium spacing system
class PremiumSpacing {
  PremiumSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

/// Premium border radius system
class PremiumRadius {
  PremiumRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;
}

/// Premium animation durations
class PremiumDurations {
  PremiumDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration energyFlow = Duration(milliseconds: 800);
  static const Duration mysticalReveal = Duration(milliseconds: 1200);
}

/// Premium animation curves
class PremiumCurves {
  PremiumCurves._();

  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve gentle = Curves.easeOutBack;
  static const Curve energyFlow = Curves.easeInOutSine;
  static const Curve mysticalReveal = Curves.easeOutExpo;
}

/// Box shadows for depth
class PremiumShadows {
  PremiumShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get premiumGlow => [
        BoxShadow(
          color: PremiumColors.premiumGold.withOpacity(0.3),
          blurRadius: 24,
          spreadRadius: 4,
        ),
      ];

  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: PremiumColors.primaryPurple.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Mystical Turkish microcopy
class MysticalStrings {
  MysticalStrings._();

  // Home & Navigation
  static const String greeting = 'Bugün Ruhun Ne Diyor?';
  static const String dailyEnergy = 'Günlük Enerji Akışı';
  static const String cosmicGuide = 'Kozmik Rehberin';
  static const String soulJourney = 'Ruh Yolculuğu';

  // Fortune & Readings
  static const String fortuneReading = 'Fal Yorumu';
  static const String deepAnalysis = 'Derin Analiz';
  static const String personalGuide = 'Özel Rehber';
  static const String energyReport = 'Enerji Raporu';
  static const String unlockDeep = 'Derinlemesine Keşfet';

  // Premium (avoid "Premium" word)
  static const String specialGuide = 'Özel Rehber';
  static const String deepInsight = 'Derin İçgörü';
  static const String exclusiveContent = 'Özel İçerik';
  static const String unlockPremium = 'Rehberliği Aç';
  static const String premiumMember = 'Özel Üye';

  // Ads (Soft - avoid "Reklam")
  static const String sponsored = 'Önerilen';
  static const String forYou = 'Senin İçin';
  static const String discover = 'Keşfet';

  // Energy Categories
  static const String loveEnergy = 'Aşk Enerjisi';
  static const String careerEnergy = 'Kariyer Akışı';
  static const String moneyEnergy = 'Bereket Enerjisi';
  static const String healthEnergy = 'Sağlık Dengesi';
  static const String soulEnergy = 'Ruhsal Denge';

  // Actions
  static const String continueReading = 'Okumaya Devam Et';
  static const String listenNow = 'Şimdi Dinle';
  static const String exploreMore = 'Daha Fazla Keşfet';
  static const String viewDetails = 'Detayları Gör';
  static const String startJourney = 'Yolculuğa Başla';

  // Feature Hints
  static const String coffeeFortuneHint = 'Fincanını çevir, kaderini oku';
  static const String dreamHint = 'Rüyalarının gizemini çöz';
  static const String tarotHint = 'Kartların sana ne söylüyor?';
  static const String horoscopeHint = 'Yıldızlar bugün ne diyor?';
  static const String natalChartHint = 'Doğum haritanı keşfet';

  // Empty States
  static const String noDataYet = 'Henüz veri yok';
  static const String startExploring = 'Keşfetmeye başla';
  static const String comingSoon = 'Çok yakında';
}
