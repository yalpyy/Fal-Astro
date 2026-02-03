import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/landing/landing_page.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fortune/fortune_upload_screen.dart';
import '../screens/fortune/fortune_result_screen.dart';
import '../screens/astro/astro_report_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/dreams/dreams_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/synastry/synastry_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/terms_screen.dart';
import '../screens/profile/about_screen.dart';
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

      // Landing page - always allow (handles its own navigation)
      if (currentPath == RoutePaths.splash) {
        return null;
      }

      // Privacy and Terms pages - always allow (accessible from landing)
      if (currentPath == RoutePaths.privacyPolicy ||
          currentPath == RoutePaths.termsOfService) {
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
      // Landing Page (replaces splash)
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const LandingPage(),
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

          // Fortune (Fal) - Tab 2
          GoRoute(
            path: RoutePaths.fortuneUpload,
            name: RouteNames.fortuneUpload,
            builder: (context, state) => const FortuneUploadScreen(),
          ),

          // Dreams (Rüya) - Tab 3
          GoRoute(
            path: RoutePaths.dreams,
            name: RouteNames.dreams,
            builder: (context, state) => const DreamsScreen(),
          ),

          // Astro - Tab 4
          GoRoute(
            path: RoutePaths.astroReport,
            name: RouteNames.astroReport,
            builder: (context, state) {
              final typeParam = state.uri.queryParameters['type'];
              return AstroReportScreen(initialType: typeParam);
            },
          ),

          // Profile - Tab 5
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),

          // History (accessible from profile or home)
          GoRoute(
            path: RoutePaths.history,
            name: RouteNames.history,
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
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

      // Astro Report Detail
      GoRoute(
        path: '/astro/report/:id',
        name: RouteNames.astroReportDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AstroReportScreen(reportId: id);
        },
      ),

      // V2 Features (outside shell - full screen)
      // Shop
      GoRoute(
        path: RoutePaths.shop,
        name: RouteNames.shop,
        builder: (context, state) => const ShopScreen(),
      ),

      // Achievements
      GoRoute(
        path: RoutePaths.achievements,
        name: RouteNames.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),

      // Synastry (Compatibility)
      GoRoute(
        path: RoutePaths.synastry,
        name: RouteNames.synastry,
        builder: (context, state) => const SynastryScreen(),
      ),

      // Admin Panel
      GoRoute(
        path: RoutePaths.admin,
        name: RouteNames.admin,
        builder: (context, state) => const AdminPanelScreen(),
      ),

      // Profile sub-screens
      GoRoute(
        path: RoutePaths.notificationSettings,
        name: RouteNames.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.privacyPolicy,
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RoutePaths.termsOfService,
        name: RouteNames.termsOfService,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
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

/// Bottom navigation bar with 5 tabs
class MainBottomNav extends ConsumerWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (currentPath.startsWith('/fortune')) {
      currentIndex = 1;
    } else if (currentPath.startsWith('/dreams')) {
      currentIndex = 2;
    } else if (currentPath.startsWith('/astro')) {
      currentIndex = 3;
    } else if (currentPath.startsWith('/profile')) {
      currentIndex = 4;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.goNamed(RouteNames.home);
            break;
          case 1:
            context.goNamed(RouteNames.fortuneUpload);
            break;
          case 2:
            context.goNamed(RouteNames.dreams);
            break;
          case 3:
            context.goNamed(RouteNames.astroReport);
            break;
          case 4:
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
          icon: Icon(Icons.coffee_outlined),
          selectedIcon: Icon(Icons.coffee),
          label: 'Fal',
        ),
        NavigationDestination(
          icon: Icon(Icons.nights_stay_outlined),
          selectedIcon: Icon(Icons.nights_stay),
          label: 'Rüya',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: 'Astro',
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
