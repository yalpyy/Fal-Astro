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

  // Validate environment
  Env.validate();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Initialize notifications (only on mobile)
  if (!kIsWeb) {
    await NotificationService().initialize();
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Error handling for web debugging
  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      log('Flutter Error: ${details.exception}');
      log('Stack trace: ${details.stack}');
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
        log('Uncaught error: $error');
        log('Stack trace: $stackTrace');
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
