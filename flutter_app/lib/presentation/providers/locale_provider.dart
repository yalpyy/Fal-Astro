import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale notifier
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _key = 'app_locale';
  SharedPreferences? _prefs;

  LocaleNotifier() : super(const Locale('tr')) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocale = _prefs?.getString(_key);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs?.setString(_key, locale.languageCode);
  }

  Future<void> setTurkish() async {
    await setLocale(const Locale('tr'));
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  Future<void> toggleLocale() async {
    if (state.languageCode == 'tr') {
      await setEnglish();
    } else {
      await setTurkish();
    }
  }
}

/// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Is Turkish provider
final isTurkishProvider = Provider<bool>((ref) {
  return ref.watch(localeProvider).languageCode == 'tr';
});

/// Locale code provider
final localeCodeProvider = Provider<String>((ref) {
  return ref.watch(localeProvider).languageCode;
});
