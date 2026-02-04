import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/astro_provider.dart';
import '../../router/route_names.dart';
import '../../widgets/common/disclaimer_banner.dart';
import '../../widgets/gamification/user_stats_card.dart';
import '../../widgets/premium/native_ad_card.dart';
import 'widgets/fortune_card.dart';
import 'widgets/astro_card.dart';
import 'widgets/daily_affirmation_card.dart';

/// Daily astro provider for home
final dailyAstroHomeProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(dailyAstroProvider.notifier);
  await notifier.loadDailyAstro();
});

/// Home screen with premium mystical design
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final dailyAstroState = ref.watch(dailyAstroProvider);

    // Debug banner for web
    if (kDebugMode || kIsWeb) {
      debugPrint('Auth Status: ${authState.status}');
      debugPrint('User ID: ${authState.user?.id}');
      debugPrint('User Email: ${authState.user?.email}');
    }

    final zodiacSign = profileState.birthProfile?.zodiacSign;
    final zodiacLabel = zodiacSign != null
        ? Formatters.zodiacLabel(zodiacSign)
        : null;
    final userName = profileState.profile?.name;

    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: PremiumColors.primaryPurple,
          backgroundColor: PremiumColors.cardBackground,
          onRefresh: () async {
            await ref.read(dailyAstroProvider.notifier).loadDailyAstro(
                  forceRefresh: true,
                );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PremiumSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug: Auth status banner (only on web)
                if (kIsWeb)
                  _DebugBanner(authState: authState),

                // Premium Header
                _PremiumHeader(
                  userName: userName,
                  zodiacLabel: zodiacLabel,
                  avatarUrl: profileState.profile?.avatarUrl,
                  onProfileTap: () => context.pushNamed(RouteNames.profile),
                ),
                const SizedBox(height: PremiumSpacing.xl),

                // User Stats (Credits, Streak, Level)
                UserStatsCard(
                  onCreditsTap: () => context.pushNamed(RouteNames.shop),
                  onAchievementsTap: () => context.pushNamed(RouteNames.achievements),
                ),
                const SizedBox(height: PremiumSpacing.lg),

                // Daily Affirmation
                if (zodiacSign != null)
                  DailyAffirmationCard(zodiacSign: zodiacSign),
                const SizedBox(height: PremiumSpacing.lg),

                // Disclaimer
                const DisclaimerBanner(),
                const SizedBox(height: PremiumSpacing.xl),

                // Section: Main Features
                const _SectionTitle(
                  title: 'Keşfet',
                  subtitle: 'Bugün ruhun ne diyor?',
                ),
                const SizedBox(height: PremiumSpacing.lg),

                // Fortune Card
                FortuneCard(
                  onTap: () => context.pushNamed(RouteNames.fortuneUpload),
                ),
                const SizedBox(height: PremiumSpacing.md),

                // Dreams Card
                DreamsCard(
                  onTap: () => context.pushNamed(RouteNames.dreams),
                ),
                const SizedBox(height: PremiumSpacing.md),

                // Daily Astro Card
                AstroCard(
                  dailyAstro: dailyAstroState.astro,
                  isLoading: dailyAstroState.isLoading,
                  zodiacLabel: zodiacLabel,
                  onTap: () => context.pushNamed(
                    RouteNames.astroReport,
                    queryParameters: {'type': 'natal'},
                  ),
                  onRefresh: () => ref.read(dailyAstroProvider.notifier).loadDailyAstro(
                        forceRefresh: true,
                      ),
                ),
                const SizedBox(height: PremiumSpacing.xl),

                // Inline Ad (Native style)
                InlineScrollAd(
                  label: 'Senin İçin',
                  adContent: Container(
                    padding: const EdgeInsets.all(PremiumSpacing.md),
                    child: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: PremiumSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Astroloji Uygulaması',
                                style: TextStyle(
                                  color: PremiumColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Burçları keşfedin',
                                style: TextStyle(
                                  color: PremiumColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: PremiumSpacing.xl),

                // Section: Reports
                const _SectionTitle(
                  title: 'Raporlar',
                  subtitle: 'Derinlemesine analizler',
                ),
                const SizedBox(height: PremiumSpacing.lg),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: PremiumSpacing.md,
                  crossAxisSpacing: PremiumSpacing.md,
                  childAspectRatio: 1.4,
                  children: [
                    _PremiumReportTile(
                      icon: '🌌',
                      title: 'Doğum Haritası',
                      color: PremiumColors.primaryPurple,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'natal'},
                      ),
                    ),
                    _PremiumReportTile(
                      icon: '💕',
                      title: 'Aşk',
                      color: PremiumColors.energyLove,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'love'},
                      ),
                    ),
                    _PremiumReportTile(
                      icon: '💼',
                      title: 'Kariyer',
                      color: PremiumColors.energyCareer,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'career'},
                      ),
                    ),
                    _PremiumReportTile(
                      icon: '📅',
                      title: 'Bu Ay',
                      color: PremiumColors.accentCyan,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'monthly'},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium header with mystical greeting
class _PremiumHeader extends StatelessWidget {
  final String? userName;
  final String? zodiacLabel;
  final String? avatarUrl;
  final VoidCallback onProfileTap;

  const _PremiumHeader({
    this.userName,
    this.zodiacLabel,
    this.avatarUrl,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: PremiumColors.textTertiary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: PremiumSpacing.xs),
              Text(
                userName != null ? 'Merhaba, $userName' : MysticalStrings.greeting,
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              if (zodiacLabel != null) ...[
                const SizedBox(height: PremiumSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumSpacing.md,
                    vertical: PremiumSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumColors.primaryPurple.withOpacity(0.2),
                        PremiumColors.accentCyan.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PremiumRadius.full),
                    border: Border.all(
                      color: PremiumColors.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    zodiacLabel!,
                    style: const TextStyle(
                      color: PremiumColors.primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Profile avatar
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PremiumColors.primaryPurple,
                  PremiumColors.accentCyan,
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: PremiumColors.cardBackground,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Text(
                      '🌙',
                      style: TextStyle(fontSize: 24),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Gece kuşu';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }
}

/// Section title with subtitle
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: PremiumColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              color: PremiumColors.textTertiary,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

/// Premium styled report tile
class _PremiumReportTile extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _PremiumReportTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: PremiumSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Debug banner for web testing
class _DebugBanner extends StatelessWidget {
  final dynamic authState;

  const _DebugBanner({required this.authState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.sm),
      margin: const EdgeInsets.only(bottom: PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: authState.isAuthenticated
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(PremiumRadius.md),
        border: Border.all(
          color: authState.isAuthenticated
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            authState.isAuthenticated
                ? Icons.check_circle
                : Icons.error,
            color: authState.isAuthenticated
                ? Colors.green
                : Colors.red,
            size: 20,
          ),
          const SizedBox(width: PremiumSpacing.sm),
          Expanded(
            child: Text(
              authState.isAuthenticated
                  ? 'Giriş yapıldı: ${authState.user?.email ?? "?"}'
                  : 'Giriş yapılmadı! Status: ${authState.status.name}',
              style: TextStyle(
                color: authState.isAuthenticated
                    ? Colors.green
                    : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
