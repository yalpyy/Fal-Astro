import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/premium_theme.dart';
import '../../providers/profile_provider.dart';

/// Premium user stats card showing streak, level, credits
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

    final credits = profile?.credits ?? 0;
    final streak = profile?.streakCount ?? 0;
    final level = profile?.level ?? 1;
    final xp = profile?.experiencePoints ?? 0;
    final xpForNextLevel = level * 100;

    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: PremiumColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              // Credits
              Expanded(
                child: _PremiumStatTile(
                  icon: '💎',
                  value: '$credits',
                  label: 'Kredi',
                  color: PremiumColors.premiumGold,
                  onTap: onCreditsTap,
                ),
              ),
              _PremiumDivider(),
              // Streak
              Expanded(
                child: _PremiumStatTile(
                  icon: '🔥',
                  value: '$streak',
                  label: 'Gün Serisi',
                  color: PremiumColors.energyHealth,
                  showGlow: streak > 0,
                ),
              ),
              _PremiumDivider(),
              // Level
              Expanded(
                child: _PremiumStatTile(
                  icon: '⭐',
                  value: 'Lv.$level',
                  label: 'Seviye',
                  color: PremiumColors.primaryPurple,
                  onTap: onAchievementsTap,
                ),
              ),
            ],
          ),

          // XP Progress bar
          const SizedBox(height: PremiumSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deneyim Puanı',
                    style: TextStyle(
                      color: PremiumColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$xp / $xpForNextLevel XP',
                    style: const TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PremiumSpacing.sm),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: PremiumColors.surfaceLight,
                  borderRadius: BorderRadius.circular(PremiumRadius.full),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (xp / xpForNextLevel).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PremiumColors.primaryPurple,
                          PremiumColors.accentCyan,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(PremiumRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumColors.primaryPurple.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumStatTile extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  final bool showGlow;
  final VoidCallback? onTap;

  const _PremiumStatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(PremiumSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: PremiumSpacing.sm),
        Text(
          value,
          style: const TextStyle(
            color: PremiumColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: PremiumColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class _PremiumDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            PremiumColors.borderSubtle,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Premium streak celebration dialog
class StreakCelebrationDialog extends StatelessWidget {
  final int streakCount;

  const StreakCelebrationDialog({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PremiumColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PremiumSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire icon with glow
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumColors.energyHealth.withOpacity(0.3),
                    PremiumColors.energyLove.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.energyHealth.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                '🔥',
                style: TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: PremiumSpacing.lg),
            Text(
              '$streakCount Gün Serisi!',
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumSpacing.sm),
            Text(
              'Harika gidiyorsun! Devam et!',
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (streakCount >= 7) ...[
              const SizedBox(height: PremiumSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumSpacing.md,
                  vertical: PremiumSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumColors.premiumGold.withOpacity(0.2),
                      PremiumColors.premiumGold.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(PremiumRadius.full),
                  border: Border.all(
                    color: PremiumColors.premiumGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: PremiumSpacing.xs),
                    Text(
                      '+5 bonus XP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.premiumGold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: PremiumSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: PremiumSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PremiumRadius.lg),
                  ),
                ),
                child: const Text(
                  'Harika!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
