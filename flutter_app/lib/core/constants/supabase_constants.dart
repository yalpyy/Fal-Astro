/// Supabase-specific constants
class SupabaseConstants {
  SupabaseConstants._();

  // Storage Buckets
  static const String fortuneImagesBucket = 'fortune-images';

  // Edge Functions
  static const String fortuneReadFunction = 'fortune_read';
  static const String dailyAstroFunction = 'daily_astro';
  static const String astroReportFunction = 'astro_report';
  static const String compatReportFunction = 'compat_report';

  // Tables
  static const String profilesTable = 'profiles';
  static const String birthProfilesTable = 'birth_profiles';
  static const String fortuneReadingsTable = 'fortune_readings';
  static const String fortuneFeedbackTable = 'fortune_feedback';
  static const String astroReportsTable = 'astro_reports';
  static const String dailyAstroCacheTable = 'daily_astro_cache';
  static const String subscriptionsTable = 'subscriptions';

  // Signed URL Expiry
  static const Duration signedUrlExpiry = Duration(hours: 1);
}
