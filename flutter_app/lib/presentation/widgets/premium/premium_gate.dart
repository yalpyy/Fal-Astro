import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Premium content gate - soft, non-aggressive unlock prompt
///
/// Design rules:
/// - Gold accent
/// - Calm language
/// - No urgency pressure
/// - Never blocks core functionality
class PremiumGate extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onUnlock;
  final VoidCallback? onWatchAd;
  final bool showWatchOption;
  final Widget? preview;

  const PremiumGate({
    super.key,
    this.title = 'Derin Analiz',
    this.description = 'Bu özel içeriğe erişmek için rehberliği aç',
    required this.onUnlock,
    this.onWatchAd,
    this.showWatchOption = true,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumColors.cardBackground.withOpacity(0.9),
            PremiumColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: PremiumColors.premiumGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview content with blur overlay
          if (preview != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(PremiumRadius.xl),
              ),
              child: Stack(
                children: [
                  preview!,
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            PremiumColors.backgroundSecondary.withOpacity(0.8),
                            PremiumColors.backgroundSecondary,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Unlock prompt
          Padding(
            padding: const EdgeInsets.all(PremiumSpacing.xl),
            child: Column(
              children: [
                // Gold icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: PremiumColors.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: PremiumShadows.premiumGlow,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF1A1A2E),
                    size: 32,
                  ),
                ),

                const SizedBox(height: PremiumSpacing.xl),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: PremiumColors.premiumGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: PremiumSpacing.md),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: PremiumSpacing.xxl),

                // Premium unlock button
                _PremiumButton(
                  label: MysticalStrings.unlockPremium,
                  onTap: onUnlock,
                  isPrimary: true,
                ),

                // Watch ad option
                if (showWatchOption && onWatchAd != null) ...[
                  const SizedBox(height: PremiumSpacing.md),
                  TextButton.icon(
                    onPressed: onWatchAd,
                    icon: Icon(
                      Icons.play_circle_outline,
                      size: 18,
                      color: PremiumColors.textTertiary,
                    ),
                    label: Text(
                      'veya izleyerek aç',
                      style: TextStyle(
                        color: PremiumColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium CTA button with gold gradient
class _PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _PremiumButton({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: PremiumSpacing.lg,
          horizontal: PremiumSpacing.xl,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? PremiumColors.goldGradient : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          border: isPrimary
              ? null
              : Border.all(
                  color: PremiumColors.premiumGold.withOpacity(0.5),
                  width: 1.5,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: PremiumColors.premiumGold.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.diamond_outlined,
              size: 20,
              color: isPrimary
                  ? const Color(0xFF1A1A2E)
                  : PremiumColors.premiumGold,
            ),
            const SizedBox(width: PremiumSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? const Color(0xFF1A1A2E)
                    : PremiumColors.premiumGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline premium hint - subtle indicator for locked content
class PremiumHint extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const PremiumHint({
    super.key,
    this.text = 'Özel İçerik',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumSpacing.md,
          vertical: PremiumSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumColors.premiumGold.withOpacity(0.15),
              PremiumColors.premiumGold.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.full),
          border: Border.all(
            color: PremiumColors.premiumGold.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: PremiumColors.premiumGold,
            ),
            const SizedBox(width: PremiumSpacing.xs),
            Text(
              text,
              style: TextStyle(
                color: PremiumColors.premiumGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium badge for user profiles
class PremiumBadge extends StatelessWidget {
  final bool isCompact;

  const PremiumBadge({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: PremiumColors.goldGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: PremiumColors.premiumGold.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.diamond,
          size: 14,
          color: Color(0xFF1A1A2E),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: PremiumColors.goldGradient,
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.premiumGold.withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond,
            size: 16,
            color: Color(0xFF1A1A2E),
          ),
          const SizedBox(width: PremiumSpacing.xs),
          const Text(
            'Özel Üye',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
