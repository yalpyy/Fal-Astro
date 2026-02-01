import 'package:flutter/foundation.dart';

/// Platform utilities for cross-platform compatibility
class PlatformUtils {
  PlatformUtils._();

  /// Whether the app is running on web
  static bool get isWeb => kIsWeb;

  /// Whether the app is running on an Apple platform (iOS or macOS)
  static bool get isApplePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Whether the app is running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Whether the app is running on macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Whether the app is running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Whether the app is running on a mobile platform (iOS or Android)
  static bool get isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Whether the app is running on a desktop platform
  static bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Whether file picking is supported (mobile only for now)
  static bool get supportsFilePicking => isMobile;
}
