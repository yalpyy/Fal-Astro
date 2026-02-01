import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/profile_provider.dart';
import '../../providers/astro_provider.dart';
import '../../router/route_names.dart';
import '../../widgets/common/disclaimer_banner.dart';
import 'widgets/fortune_card.dart';
import 'widgets/astro_card.dart';

/// Daily astro provider for home
final dailyAstroHomeProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(dailyAstroProvider.notifier);
  await notifier.loadDailyAstro();
});

/// Home screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final dailyAstroState = ref.watch(dailyAstroProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final zodiacSign = profileState.birthProfile?.zodiacSign;
    final zodiacLabel = zodiacSign != null
        ? Formatters.zodiacLabel(zodiacSign)
        : null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dailyAstroProvider.notifier).loadDailyAstro(
                  forceRefresh: true,
                );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merhaba${profileState.profile?.name != null ? ", ${profileState.profile!.name}" : ""}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (zodiacLabel != null)
                            Text(
                              zodiacLabel,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Disclaimer
                const DisclaimerBanner(),
                const SizedBox(height: 24),

                // Main cards
                Text(
                  'Bugün Ne Yapmak İstersin?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),

                // Fortune Card
                FortuneCard(
                  onTap: () => context.pushNamed(RouteNames.fortuneUpload),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

                // Quick actions
                Text(
                  'Raporlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _ReportTile(
                      icon: Icons.auto_awesome,
                      title: 'Doğum Haritası',
                      color: Colors.purple,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'natal'},
                      ),
                    ),
                    _ReportTile(
                      icon: Icons.favorite,
                      title: 'Aşk',
                      color: Colors.pink,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'love'},
                      ),
                    ),
                    _ReportTile(
                      icon: Icons.work,
                      title: 'Kariyer',
                      color: Colors.blue,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'career'},
                      ),
                    ),
                    _ReportTile(
                      icon: Icons.calendar_month,
                      title: 'Bu Ay',
                      color: Colors.teal,
                      onTap: () => context.pushNamed(
                        RouteNames.astroReport,
                        queryParameters: {'type': 'monthly'},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
