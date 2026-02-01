import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'env/env.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment - returns false if not configured
  final isConfigured = Env.validate();

  // Initialize Supabase only if configured
  if (isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Initialize notifications (only on mobile)
    if (!kIsWeb) {
      await NotificationService().initialize();
    }
  } else {
    debugPrint('Running in demo mode - Supabase not configured');
  }

  // Set preferred orientations (skip on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Error handling for web debugging
  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to browser console
      // ignore: avoid_print
      print('🔴 Flutter Error: ${details.exception}');
      // ignore: avoid_print
      print('Stack trace: ${details.stack}');
    };

    runZonedGuarded(
      () {
        runApp(
          const ProviderScope(
            child: FalAstroApp(),
          ),
        );
      },
      (error, stackTrace) {
        // Log to browser console
        // ignore: avoid_print
        print('🔴 Uncaught error: $error');
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
      },
    );
  } else {
    // Run app with Riverpod
    runApp(
      const ProviderScope(
        child: FalAstroApp(),
      ),
    );
  }
}
