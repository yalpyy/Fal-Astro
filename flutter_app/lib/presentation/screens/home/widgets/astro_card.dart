import 'package:flutter/material.dart';
import '../../../../core/theme/premium_theme.dart';
import '../../../../data/models/daily_astro.dart';
import '../../../widgets/premium/energy_ring.dart';

/// Premium daily astro card on home screen
class AstroCard extends StatelessWidget {
  final DailyAstro? dailyAstro;
  final bool isLoading;
  final String? zodiacLabel;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const AstroCard({
    super.key,
    this.dailyAstro,
    this.isLoading = false,
    this.zodiacLabel,
    required this.onTap,
    required this.onRefresh,
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
              PremiumColors.cardBackground,
              PremiumColors.surfaceLight.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.accentCyan.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PremiumSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PremiumColors.accentCyan.withOpacity(0.2),
                        PremiumColors.primaryPurple.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PremiumRadius.md),
                  ),
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: PremiumSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günlük Astroloji',
                        style: TextStyle(
                          color: PremiumColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (zodiacLabel != null)
                        Text(
                          zodiacLabel!,
                          style: const TextStyle(
                            color: PremiumColors.accentCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Refresh button
                GestureDetector(
                  onTap: isLoading ? null : onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(PremiumSpacing.sm),
                    decoration: BoxDecoration(
                      color: PremiumColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PremiumColors.accentCyan,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: PremiumColors.textSecondary,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PremiumSpacing.lg),

            // Content
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(PremiumSpacing.xl),
                  child: CircularProgressIndicator(
                    color: PremiumColors.primaryPurple,
                  ),
                ),
              )
            else if (dailyAstro != null) ...[
              // Astro content preview
              Text(
                dailyAstro!.content.length > 120
                    ? '${dailyAstro!.content.substring(0, 120)}...'
                    : dailyAstro!.content,
                style: const TextStyle(
                  color: PremiumColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: PremiumSpacing.lg),

              // Energy scores row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniEnergyRing(
                    label: 'Mod',
                    value: dailyAstro!.moodScore / 10,
                    color: PremiumColors.energyLove,
                    icon: '😊',
                  ),
                  _MiniEnergyRing(
                    label: 'Şans',
                    value: (dailyAstro!.moodScore + 2).clamp(0, 10) / 10,
                    color: PremiumColors.energyMoney,
                    icon: '🍀',
                  ),
                  _MiniEnergyRing(
                    label: 'Enerji',
                    value: (dailyAstro!.moodScore - 1).clamp(0, 10) / 10,
                    color: PremiumColors.accentCyan,
                    icon: '⚡',
                  ),
                ],
              ),
              const SizedBox(height: PremiumSpacing.md),

              // Lucky info chips
              Wrap(
                spacing: PremiumSpacing.sm,
                runSpacing: PremiumSpacing.sm,
                children: [
                  _PremiumChip(
                    icon: '🎨',
                    label: dailyAstro!.luckyColor,
                  ),
                  if (dailyAstro!.luckyNumber != null)
                    _PremiumChip(
                      icon: '🔢',
                      label: '${dailyAstro!.luckyNumber}',
                    ),
                ],
              ),
            ] else
              // Empty state
              Container(
                padding: const EdgeInsets.all(PremiumSpacing.xl),
                child: Column(
                  children: [
                    const Text(
                      '🌟',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: PremiumSpacing.md),
                    Text(
                      MysticalStrings.greeting,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mini energy ring for astro card
class _MiniEnergyRing extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String icon;

  const _MiniEnergyRing({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              EnergyRing(
                value: value,
                color: color,
                size: 56,
                strokeWidth: 4,
                showGlow: true,
              ),
              Text(icon, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: PremiumSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: PremiumColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Premium styled chip
class _PremiumChip extends StatelessWidget {
  final String icon;
  final String label;

  const _PremiumChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceLight,
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        border: Border.all(
          color: PremiumColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: PremiumSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
