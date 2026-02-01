/// Route names for navigation
class RouteNames {
  RouteNames._();

  // Root
  static const String splash = 'splash';
  static const String auth = 'auth';
  static const String onboarding = 'onboarding';

  // Main tabs
  static const String home = 'home';
  static const String history = 'history';
  static const String profile = 'profile';

  // Fortune
  static const String fortuneUpload = 'fortune-upload';
  static const String fortuneResult = 'fortune-result';
  static const String fortuneDetail = 'fortune-detail';

  // Astro
  static const String dailyAstro = 'daily-astro';
  static const String astroReport = 'astro-report';
  static const String astroReportDetail = 'astro-report-detail';
  static const String compatReport = 'compat-report';

  // Settings
  static const String settings = 'settings';
  static const String languageSettings = 'language-settings';
  static const String themeSettings = 'theme-settings';
  static const String notificationSettings = 'notification-settings';
  static const String privacyPolicy = 'privacy-policy';
  static const String termsOfService = 'terms-of-service';

  // Premium
  static const String premium = 'premium';
}

/// Route paths
class RoutePaths {
  RoutePaths._();

  // Root
  static const String splash = '/';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';

  // Main
  static const String home = '/home';
  static const String history = '/history';
  static const String profile = '/profile';

  // Fortune
  static const String fortuneUpload = '/fortune/upload';
  static const String fortuneResult = '/fortune/result/:id';
  static const String fortuneDetail = '/fortune/:id';

  // Astro
  static const String dailyAstro = '/astro/daily';
  static const String astroReport = '/astro/report';
  static const String astroReportDetail = '/astro/report/:id';
  static const String compatReport = '/astro/compat';

  // Settings
  static const String settings = '/settings';
  static const String languageSettings = '/settings/language';
  static const String themeSettings = '/settings/theme';
  static const String notificationSettings = '/settings/notifications';
  static const String privacyPolicy = '/settings/privacy';
  static const String termsOfService = '/settings/terms';

  // Premium
  static const String premium = '/premium';
}
