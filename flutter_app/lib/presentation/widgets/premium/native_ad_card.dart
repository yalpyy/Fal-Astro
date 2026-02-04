import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Native ad card that blends with premium content
///
/// Design rules:
/// - Same card radius as content
/// - Muted background
/// - Clear spacing
/// - Small "Önerilen" label (low contrast)
/// - Never interrupts user actions
class NativeAdCard extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final String label;
  final double? height;

  const NativeAdCard({
    super.key,
    this.child,
    this.onTap,
    this.label = 'Önerilen',
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.lg,
        vertical: PremiumSpacing.md,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: PremiumColors.adContainerBackground,
            borderRadius: BorderRadius.circular(PremiumRadius.lg),
            border: Border.all(
              color: PremiumColors.borderSubtle.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle "Önerilen" label
              Padding(
                padding: const EdgeInsets.only(
                  left: PremiumSpacing.md,
                  top: PremiumSpacing.sm,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: PremiumColors.textTertiary.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Ad content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(PremiumSpacing.md),
                  child: child ?? const _AdPlaceholder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for when ad is loading or not available
class _AdPlaceholder extends StatelessWidget {
  const _AdPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 32,
            color: PremiumColors.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: PremiumSpacing.sm),
          Text(
            MysticalStrings.forYou,
            style: TextStyle(
              color: PremiumColors.textTertiary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline scroll ad that fits naturally in content flow
class InlineScrollAd extends StatelessWidget {
  final Widget adContent;
  final String label;

  const InlineScrollAd({
    super.key,
    required this.adContent,
    this.label = 'Senin İçin',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: PremiumSpacing.lg),
      padding: const EdgeInsets.all(PremiumSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.adContainerBackground,
            PremiumColors.cardBackground.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.lg),
        border: Border.all(
          color: PremiumColors.borderSubtle.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumSpacing.sm,
                  vertical: PremiumSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: PremiumColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PremiumRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 12,
                      color: PremiumColors.primaryPurple.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: PremiumColors.textTertiary.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumSpacing.md),
          adContent,
        ],
      ),
    );
  }
}

/// Rewarded ad prompt (watch to unlock content)
class RewardedAdPrompt extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onWatch;
  final VoidCallback? onSkip;
  final IconData icon;

  const RewardedAdPrompt({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onWatch,
    this.onSkip,
    this.icon = Icons.play_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.cardElevated,
            PremiumColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: PremiumColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: PremiumColors.primaryPurple.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PremiumColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: PremiumColors.primaryPurple,
            ),
          ),

          const SizedBox(height: PremiumSpacing.lg),

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

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: PremiumSpacing.xl),

          // Watch button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onWatch,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('İzle ve Aç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.primaryPurple,
                foregroundColor: PremiumColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: PremiumSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadius.md),
                ),
              ),
            ),
          ),

          if (onSkip != null) ...[
            const SizedBox(height: PremiumSpacing.md),
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Şimdilik Geç',
                style: TextStyle(
                  color: PremiumColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
