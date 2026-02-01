import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fortune/fortune_upload_screen.dart';
import '../screens/fortune/fortune_result_screen.dart';
import '../screens/astro/astro_report_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'route_names.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final profileState = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = profileState.isOnboarded;
      final currentPath = state.uri.path;

      // Splash screen - always allow
      if (currentPath == RoutePaths.splash) {
        return null;
      }

      // Not authenticated - go to auth
      if (!isAuthenticated) {
        if (currentPath == RoutePaths.auth) {
          return null;
        }
        return RoutePaths.auth;
      }

      // Authenticated but not onboarded - go to onboarding
      if (!isOnboarded && !profileState.isLoading) {
        if (currentPath == RoutePaths.onboarding) {
          return null;
        }
        return RoutePaths.onboarding;
      }

      // Authenticated and onboarded - redirect away from auth/onboarding
      if (currentPath == RoutePaths.auth || currentPath == RoutePaths.onboarding) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: RoutePaths.auth,
        name: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Shell Route for main navigation with bottom nav bar
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),

          // History
          GoRoute(
            path: RoutePaths.history,
            name: RouteNames.history,
            builder: (context, state) => const HistoryScreen(),
          ),

          // Profile
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Fortune Upload
      GoRoute(
        path: RoutePaths.fortuneUpload,
        name: RouteNames.fortuneUpload,
        builder: (context, state) => const FortuneUploadScreen(),
      ),

      // Fortune Result
      GoRoute(
        path: '/fortune/result/:id',
        name: RouteNames.fortuneResult,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FortuneResultScreen(readingId: id);
        },
      ),

      // Fortune Detail (from history)
      GoRoute(
        path: '/fortune/:id',
        name: RouteNames.fortuneDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FortuneResultScreen(readingId: id);
        },
      ),

      // Astro Report
      GoRoute(
        path: RoutePaths.astroReport,
        name: RouteNames.astroReport,
        builder: (context, state) {
          final typeParam = state.uri.queryParameters['type'];
          return AstroReportScreen(initialType: typeParam);
        },
      ),

      // Astro Report Detail
      GoRoute(
        path: '/astro/report/:id',
        name: RouteNames.astroReportDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AstroReportScreen(reportId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri.path}'),
      ),
    ),
  );
});

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MainBottomNav(),
    );
  }
}

/// Bottom navigation bar
class MainBottomNav extends ConsumerWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (currentPath.startsWith('/history')) {
      currentIndex = 1;
    } else if (currentPath.startsWith('/profile')) {
      currentIndex = 2;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.goNamed(RouteNames.home);
            break;
          case 1:
            context.goNamed(RouteNames.history);
            break;
          case 2:
            context.goNamed(RouteNames.profile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Geçmiş',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

/// GoRouter refresh stream helper
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
