import 'package:flutter/foundation.dart';

/// Environment configuration
/// Use --dart-define to set values:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx

class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Validate configuration - logs warning instead of throwing
  /// Returns true if configured, false otherwise
  static bool validate() {
    if (!isConfigured) {
      debugPrint(
        'WARNING: Supabase configuration missing. '
        'Use --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx',
      );
      return false;
    }
    return true;
  }

  /// Throws if not configured - use only when configuration is required
  static void requireConfiguration() {
    if (!isConfigured) {
      throw StateError(
        'Supabase configuration missing. '
        'Use --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx',
      );
    }
  }
}
