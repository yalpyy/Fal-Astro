import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

/// All achievements provider
final allAchievementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(safeSupabaseClientProvider);
  if (supabase == null) return [];

  final response = await supabase
      .from('achievements')
      .select()
      .eq('is_active', true)
      .order('points');

  return List<Map<String, dynamic>>.from(response);
});

/// User achievements provider
final userAchievementsProvider = FutureProvider<List<String>>((ref) async {
  final supabase = ref.read(safeSupabaseClientProvider);
  final authState = ref.watch(authProvider);

  if (supabase == null || !authState.isAuthenticated) return [];

  final response = await supabase
      .from('user_achievements')
      .select('achievement_id')
      .eq('user_id', authState.user!.id);

  return List<Map<String, dynamic>>.from(response)
      .map((e) => e['achievement_id'] as String)
      .toList();
});

/// Achievements screen
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılar'),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (achievements) {
          final userAchievements = userAchievementsAsync.valueOrNull ?? [];
          final earnedCount = userAchievements.length;
          final totalPoints = achievements
              .where((a) => userAchievements.contains(a['id']))
              .fold<int>(0, (sum, a) => sum + (a['points'] as int? ?? 0));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats card
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatColumn(
                            icon: Icons.emoji_events,
                            value: '$earnedCount/${achievements.length}',
                            label: 'Kazanılan',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                        ),
                        Expanded(
                          child: _StatColumn(
                            icon: Icons.star,
                            value: '$totalPoints',
                            label: 'Toplam Puan',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'İlerleme',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${((earnedCount / achievements.length) * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: achievements.isEmpty ? 0 : earnedCount / achievements.length,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Achievements by category
                ..._buildCategorySection(
                  context,
                  'Okuma Başarıları',
                  Icons.menu_book,
                  achievements.where((a) => a['category'] == 'reading').toList(),
                  userAchievements,
                ),
                ..._buildCategorySection(
                  context,
                  'Seri Başarıları',
                  Icons.local_fire_department,
                  achievements.where((a) => a['category'] == 'streak').toList(),
                  userAchievements,
                ),
                ..._buildCategorySection(
                  context,
                  'Sosyal Başarılar',
                  Icons.share,
                  achievements.where((a) => a['category'] == 'social').toList(),
                  userAchievements,
                ),
                ..._buildCategorySection(
                  context,
                  'Özel Başarılar',
                  Icons.auto_awesome,
                  achievements.where((a) => a['category'] == 'special').toList(),
                  userAchievements,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategorySection(
    BuildContext context,
    String title,
    IconData icon,
    List<Map<String, dynamic>> achievements,
    List<String> userAchievements,
  ) {
    if (achievements.isEmpty) return [];

    return [
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...achievements.map((achievement) => _AchievementCard(
            achievement: achievement,
            isEarned: userAchievements.contains(achievement['id']),
          )),
      const SizedBox(height: 16),
    ];
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final bool isEarned;

  const _AchievementCard({
    required this.achievement,
    required this.isEarned,
  });

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee;
      case 'star':
        return Icons.star;
      case 'moon':
        return Icons.nightlight_round;
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'share':
        return Icons.share;
      case 'stars':
        return Icons.auto_awesome;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final points = achievement['points'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isEarned ? null : colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isEarned
                    ? colorScheme.primaryContainer
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(achievement['icon_name']),
                color: isEarned ? colorScheme.primary : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title_tr'] ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEarned ? null : Colors.grey,
                        ),
                  ),
                  Text(
                    achievement['description_tr'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isEarned
                              ? colorScheme.onSurface.withOpacity(0.7)
                              : Colors.grey,
                        ),
                  ),
                ],
              ),
            ),

            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned
                    ? Colors.amber.withOpacity(0.2)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: isEarned ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$points',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEarned ? Colors.amber.shade700 : Colors.grey,
                        ),
                  ),
                ],
              ),
            ),

            // Check mark for earned
            if (isEarned) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
