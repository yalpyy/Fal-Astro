import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/landing/landing_page.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fortune/fortune_upload_screen.dart';
import '../screens/fortune/fortune_result_screen.dart';
import '../screens/astro/astro_report_screen.dart';
import '../screens/horoscope/daily_horoscope_screen.dart';
import '../screens/horoscope/zodiac_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_page.dart';
import '../screens/dreams/dreams_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/synastry/synastry_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/terms_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/credit_history_screen.dart';
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

          // Daily Horoscope (Burçlar) - Tab 4
          GoRoute(
            path: RoutePaths.dailyHoroscope,
            name: RouteNames.dailyHoroscope,
            builder: (context, state) => const DailyHoroscopeScreen(),
          ),

          // Astro Report (accessible from horoscope or home)
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

      // Zodiac Detail (full screen with Hero)
      GoRoute(
        path: RoutePaths.zodiacDetail,
        name: RouteNames.zodiacDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ZodiacDetailScreen(zodiacId: id);
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

      // Settings
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.creditHistory,
        name: RouteNames.creditHistory,
        builder: (context, state) => const CreditHistoryScreen(),
      ),

      // Profile sub-screens
      GoRoute(
        path: RoutePaths.profileEdit,
        name: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditPage(),
      ),
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

/// Main shell with premium bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      body: child,
      bottomNavigationBar: const PremiumBottomNav(),
    );
  }
}

/// Premium styled bottom navigation bar with glow effects
class PremiumBottomNav extends ConsumerWidget {
  const PremiumBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (currentPath.startsWith('/fortune')) {
      currentIndex = 1;
    } else if (currentPath.startsWith('/dreams')) {
      currentIndex = 2;
    } else if (currentPath.startsWith('/horoscope') || currentPath.startsWith('/astro')) {
      currentIndex = 3;
    } else if (currentPath.startsWith('/profile')) {
      currentIndex = 4;
    }

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: PremiumColors.borderSubtle,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PremiumSpacing.md,
            vertical: PremiumSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PremiumNavItem(
                icon: '🏠',
                label: 'Ana Sayfa',
                isSelected: currentIndex == 0,
                onTap: () => context.goNamed(RouteNames.home),
              ),
              _PremiumNavItem(
                icon: '☕',
                label: 'Fal',
                isSelected: currentIndex == 1,
                onTap: () => context.goNamed(RouteNames.fortuneUpload),
              ),
              _PremiumNavItem(
                icon: '🌙',
                label: 'Rüya',
                isSelected: currentIndex == 2,
                onTap: () => context.goNamed(RouteNames.dreams),
              ),
              _PremiumNavItem(
                icon: '✨',
                label: 'Burçlar',
                isSelected: currentIndex == 3,
                onTap: () => context.goNamed(RouteNames.dailyHoroscope),
              ),
              _PremiumNavItem(
                icon: '👤',
                label: 'Profil',
                isSelected: currentIndex == 4,
                onTap: () => context.goNamed(RouteNames.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single premium navigation item with glow
class _PremiumNavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: PremiumDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumSpacing.md,
          vertical: PremiumSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? PremiumColors.primaryPurple.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PremiumColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: PremiumDurations.fast,
              style: TextStyle(
                color: isSelected
                    ? PremiumColors.primaryPurple
                    : PremiumColors.textTertiary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// GoRouter refresh stream helper
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
