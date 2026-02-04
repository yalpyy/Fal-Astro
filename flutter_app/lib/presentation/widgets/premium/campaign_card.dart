import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Seasonal/promotional campaign card
class CampaignCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? emoji;
  final LinearGradient? gradient;
  final bool isCompact;

  const CampaignCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
    this.icon,
    this.emoji,
    this.gradient,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.primaryPurple.withOpacity(0.2),
            PremiumColors.primaryPurpleDark.withOpacity(0.1),
          ],
        );

    if (isCompact) {
      return _buildCompact(cardGradient);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.xl),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon/Emoji
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 40))
            else if (icon != null)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PremiumColors.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(PremiumRadius.md),
                ),
                child: Icon(
                  icon,
                  color: PremiumColors.primaryPurple,
                  size: 28,
                ),
              ),

            const SizedBox(width: PremiumSpacing.lg),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PremiumSpacing.xs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: PremiumColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(LinearGradient cardGradient) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          border: Border.all(
            color: PremiumColors.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 24))
            else if (icon != null)
              Icon(icon, color: PremiumColors.primaryPurple, size: 24),

            const SizedBox(width: PremiumSpacing.md),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: PremiumColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Special event banner (e.g., full moon, mercury retrograde)
class AstrologyEventBanner extends StatelessWidget {
  final String title;
  final String description;
  final DateTime eventDate;
  final Color accentColor;
  final String emoji;
  final VoidCallback? onTap;

  const AstrologyEventBanner({
    super.key,
    required this.title,
    required this.description,
    required this.eventDate,
    this.accentColor = PremiumColors.primaryPurple,
    this.emoji = '🌙',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.2),
              accentColor.withOpacity(0.05),
              PremiumColors.cardBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: PremiumSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(eventDate),
                        style: TextStyle(
                          color: PremiumColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _CountdownBadge(targetDate: eventDate),
              ],
            ),

            const SizedBox(height: PremiumSpacing.lg),

            // Description
            Text(
              description,
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: PremiumSpacing.lg),

            // CTA
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumSpacing.lg,
                vertical: PremiumSpacing.md,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(PremiumRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MysticalStrings.exploreMore,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: PremiumSpacing.xs),
                  Icon(
                    Icons.arrow_forward,
                    color: accentColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _CountdownBadge extends StatelessWidget {
  final DateTime targetDate;

  const _CountdownBadge({required this.targetDate});

  @override
  Widget build(BuildContext context) {
    final daysUntil = targetDate.difference(DateTime.now()).inDays;

    if (daysUntil < 0) return const SizedBox.shrink();

    String text;
    if (daysUntil == 0) {
      text = 'Bugün';
    } else if (daysUntil == 1) {
      text = 'Yarın';
    } else {
      text = '$daysUntil gün';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        border: Border.all(
          color: PremiumColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: PremiumColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Premium feature highlight card
class FeatureHighlightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isPremium;
  final VoidCallback? onTap;

  const FeatureHighlightCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isPremium = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          color: PremiumColors.cardBackground,
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          border: Border.all(
            color: isPremium
                ? PremiumColors.premiumGold.withOpacity(0.3)
                : PremiumColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPremium
                        ? PremiumColors.premiumGold.withOpacity(0.15)
                        : PremiumColors.primaryPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(PremiumRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: isPremium
                        ? PremiumColors.premiumGold
                        : PremiumColors.primaryPurple,
                    size: 22,
                  ),
                ),
                const Spacer(),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumSpacing.sm,
                      vertical: PremiumSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: PremiumColors.goldGradient,
                      borderRadius: BorderRadius.circular(PremiumRadius.sm),
                    ),
                    child: const Text(
                      'ÖZEL',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PremiumSpacing.md),
            Text(
              title,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PremiumSpacing.xs),
            Text(
              description,
              style: TextStyle(
                color: PremiumColors.textTertiary,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state with promotion placeholder
class EmptyStateWithPromo extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? promoCard;

  const EmptyStateWithPromo({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.promoCard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PremiumSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: PremiumColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: PremiumColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 36,
              color: PremiumColors.textTertiary,
            ),
          ),

          const SizedBox(height: PremiumSpacing.xl),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: PremiumColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: PremiumSpacing.sm),

          // Description
          Text(
            description,
            style: TextStyle(
              color: PremiumColors.textTertiary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Promo card placeholder
          if (promoCard != null) ...[
            const SizedBox(height: PremiumSpacing.xxl),
            promoCard!,
          ],
        ],
      ),
    );
  }
}
