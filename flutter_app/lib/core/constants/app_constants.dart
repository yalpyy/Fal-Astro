/// Application constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Fal & Astro';
  static const String appVersion = '1.0.0';

  // Feature Limits (Free Tier)
  static const int freeDailyFortuneLimit = 1;
  static const int freeDailyAstroReportLimit = 1;
  static const int freeDailyAstroLimit = 3;

  // Cache
  static const int maxCachedFortunes = 10;
  static const int maxCachedReports = 10;
  static const Duration cacheDuration = Duration(hours: 24);

  // Feedback
  static const int feedbackReminderDays = 7;

  // Image
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;
  static const int imageMaxWidth = 1024;
  static const int imageMaxHeight = 1024;

  // Intents
  static const List<String> fortuneIntents = [
    'love',
    'money',
    'career',
    'general',
  ];

  // Report Types
  static const List<String> reportTypes = [
    'natal',
    'weekly',
    'monthly',
    'yearly',
    'love',
    'career',
  ];
}
