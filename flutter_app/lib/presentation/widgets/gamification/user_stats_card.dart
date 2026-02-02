import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';

/// User stats card showing streak, level, credits
class UserStatsCard extends ConsumerWidget {
  final VoidCallback? onCreditsTap;
  final VoidCallback? onAchievementsTap;

  const UserStatsCard({
    super.key,
    this.onCreditsTap,
    this.onAchievementsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final colorScheme = Theme.of(context).colorScheme;

    final credits = profile?.credits ?? 0;
    final streak = profile?.streakCount ?? 0;
    final level = profile?.level ?? 1;
    final xp = profile?.experiencePoints ?? 0;
    final xpForNextLevel = level * 100; // Simple formula

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main stats row
            Row(
              children: [
                // Credits
                Expanded(
                  child: _StatTile(
                    icon: Icons.monetization_on,
                    iconColor: Colors.amber,
                    value: '$credits',
                    label: 'Kredi',
                    onTap: onCreditsTap,
                  ),
                ),
                _VerticalDivider(),
                // Streak
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    value: '$streak',
                    label: 'Gün Serisi',
                    suffix: streak > 0 ? '🔥' : null,
                  ),
                ),
                _VerticalDivider(),
                // Level
                Expanded(
                  child: _StatTile(
                    icon: Icons.emoji_events,
                    iconColor: colorScheme.primary,
                    value: 'Lv.$level',
                    label: 'Seviye',
                    onTap: onAchievementsTap,
                  ),
                ),
              ],
            ),

            // XP Progress bar
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deneyim Puanı',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                    Text(
                      '$xp / $xpForNextLevel XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xp / xpForNextLevel,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? suffix;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (suffix != null) Text(suffix!),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }
}

/// Streak celebration dialog
class StreakCelebrationDialog extends StatelessWidget {
  final int streakCount;

  const StreakCelebrationDialog({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            '$streakCount Gün Serisi!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Harika gidiyorsun! Devam et!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (streakCount >= 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '+5 bonus XP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Harika!'),
        ),
      ],
    );
  }
}
