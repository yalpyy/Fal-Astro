import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/fortune_reading.dart';
import '../models/daily_astro.dart';
import '../models/astro_report.dart';

/// Local cache service using SharedPreferences
class LocalCacheService {
  static const String _fortunesCacheKey = 'cached_fortunes';
  static const String _dailyAstroCacheKey = 'cached_daily_astro';
  static const String _astroReportsCacheKey = 'cached_astro_reports';
  static const String _themeKey = 'app_theme';
  static const String _localeKey = 'app_locale';

  final SharedPreferences _prefs;

  LocalCacheService(this._prefs);

  // ============== Fortune Cache ==============

  /// Cache fortune readings (last N)
  Future<void> cacheFortuneReadings(List<FortuneReading> readings) async {
    final limited = readings.take(AppConstants.maxCachedFortunes).toList();
    final json = limited.map((r) => r.toJson()).toList();
    await _prefs.setString(_fortunesCacheKey, jsonEncode(json));
  }

  /// Get cached fortune readings
  List<FortuneReading> getCachedFortuneReadings() {
    final jsonStr = _prefs.getString(_fortunesCacheKey);
    if (jsonStr == null) return [];

    try {
      final json = jsonDecode(jsonStr) as List;
      return json
          .map((j) => FortuneReading.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a new fortune reading to cache
  Future<void> addFortuneToCache(FortuneReading reading) async {
    final current = getCachedFortuneReadings();
    final updated = [reading, ...current.where((r) => r.id != reading.id)]
        .take(AppConstants.maxCachedFortunes)
        .toList();
    await cacheFortuneReadings(updated);
  }

  // ============== Daily Astro Cache ==============

  /// Cache daily astro
  Future<void> cacheDailyAstro(DailyAstro astro) async {
    await _prefs.setString(_dailyAstroCacheKey, jsonEncode(astro.toJson()));
  }

  /// Get cached daily astro
  DailyAstro? getCachedDailyAstro() {
    final jsonStr = _prefs.getString(_dailyAstroCacheKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final astro = DailyAstro.fromJson(json);
      // Only return if it's today's astro
      if (astro.isToday) return astro;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ============== Astro Reports Cache ==============

  /// Cache astro reports (last N)
  Future<void> cacheAstroReports(List<AstroReport> reports) async {
    final limited = reports.take(AppConstants.maxCachedReports).toList();
    final json = limited.map((r) => r.toJson()).toList();
    await _prefs.setString(_astroReportsCacheKey, jsonEncode(json));
  }

  /// Get cached astro reports
  List<AstroReport> getCachedAstroReports() {
    final jsonStr = _prefs.getString(_astroReportsCacheKey);
    if (jsonStr == null) return [];

    try {
      final json = jsonDecode(jsonStr) as List;
      return json
          .map((j) => AstroReport.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a new astro report to cache
  Future<void> addReportToCache(AstroReport report) async {
    final current = getCachedAstroReports();
    final updated = [report, ...current.where((r) => r.id != report.id)]
        .take(AppConstants.maxCachedReports)
        .toList();
    await cacheAstroReports(updated);
  }

  // ============== Settings Cache ==============

  /// Get dark mode setting
  bool? getDarkMode() {
    return _prefs.getBool(_themeKey);
  }

  /// Set dark mode setting
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_themeKey, value);
  }

  /// Get locale setting
  String? getLocale() {
    return _prefs.getString(_localeKey);
  }

  /// Set locale setting
  Future<void> setLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  // ============== Clear ==============

  /// Clear all cache
  Future<void> clearAll() async {
    await _prefs.remove(_fortunesCacheKey);
    await _prefs.remove(_dailyAstroCacheKey);
    await _prefs.remove(_astroReportsCacheKey);
  }
}
