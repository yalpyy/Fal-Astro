import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/premium_theme.dart';
import 'subscription_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// PREMIUM UX PROVIDERS
// Providers for premium vs free user experience management
// ═══════════════════════════════════════════════════════════════════

/// Whether to show ads to the current user
/// Premium users don't see ads
final showAdsProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return !isPremium;
});

/// Ad frequency limiter - tracks when last ad was shown
final adFrequencyProvider = StateNotifierProvider<AdFrequencyNotifier, AdFrequencyState>((ref) {
  return AdFrequencyNotifier();
});

class AdFrequencyState {
  final DateTime? lastAdShown;
  final int adsShownToday;
  final DateTime? dayStart;

  const AdFrequencyState({
    this.lastAdShown,
    this.adsShownToday = 0,
    this.dayStart,
  });

  AdFrequencyState copyWith({
    DateTime? lastAdShown,
    int? adsShownToday,
    DateTime? dayStart,
  }) {
    return AdFrequencyState(
      lastAdShown: lastAdShown ?? this.lastAdShown,
      adsShownToday: adsShownToday ?? this.adsShownToday,
      dayStart: dayStart ?? this.dayStart,
    );
  }

  /// Minimum time between ads (2 minutes)
  bool get canShowAd {
    if (lastAdShown == null) return true;
    final diff = DateTime.now().difference(lastAdShown!);
    return diff.inMinutes >= 2;
  }

  /// Max 5 interstitial ads per day
  bool get dailyLimitReached => adsShownToday >= 5;
}

class AdFrequencyNotifier extends StateNotifier<AdFrequencyState> {
  AdFrequencyNotifier() : super(const AdFrequencyState());

  void recordAdShown() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset counter if new day
    if (state.dayStart == null || state.dayStart!.isBefore(today)) {
      state = AdFrequencyState(
        lastAdShown: now,
        adsShownToday: 1,
        dayStart: today,
      );
    } else {
      state = state.copyWith(
        lastAdShown: now,
        adsShownToday: state.adsShownToday + 1,
      );
    }
  }
}

/// Premium feature types
enum PremiumFeature {
  unlimitedFortune,
  detailedAnalysis,
  monthlyReport,
  adFree,
  prioritySupport,
  exclusiveContent,
}

/// Check if a feature is available for current user
final featureAvailableProvider = Provider.family<bool, PremiumFeature>((ref, feature) {
  final isPremium = ref.watch(isPremiumProvider);

  // Free features available to everyone
  const freeFeatures = <PremiumFeature>[
    // Basic features are free
  ];

  if (freeFeatures.contains(feature)) return true;
  return isPremium;
});

/// Premium feature gate widget
class PremiumFeatureGate extends ConsumerWidget {
  final PremiumFeature feature;
  final Widget child;
  final Widget? lockedChild;
  final VoidCallback? onLockedTap;

  const PremiumFeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.lockedChild,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(featureAvailableProvider(feature));

    if (isAvailable) {
      return child;
    }

    return lockedChild ?? _DefaultLockedWidget(
      feature: feature,
      onTap: onLockedTap,
    );
  }
}

class _DefaultLockedWidget extends StatelessWidget {
  final PremiumFeature feature;
  final VoidCallback? onTap;

  const _DefaultLockedWidget({
    required this.feature,
    this.onTap,
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
              PremiumColors.premiumGold.withOpacity(0.1),
              PremiumColors.premiumGold.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.premiumGold.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.md),
              decoration: BoxDecoration(
                color: PremiumColors.premiumGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Text('👑', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: PremiumSpacing.md),
            const Text(
              'Özel Rehber İçeriği',
              style: TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumSpacing.xs),
            Text(
              _getFeatureDescription(feature),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: PremiumSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumSpacing.lg,
                vertical: PremiumSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumColors.premiumGold,
                    PremiumColors.premiumGoldDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(PremiumRadius.full),
              ),
              child: const Text(
                'Keşfet',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureDescription(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.unlimitedFortune:
        return 'Sınırsız fal yorumu için Özel Rehber\'e geçin';
      case PremiumFeature.detailedAnalysis:
        return 'Derinlemesine analiz için Özel Rehber\'e geçin';
      case PremiumFeature.monthlyReport:
        return 'Aylık enerji raporu için Özel Rehber\'e geçin';
      case PremiumFeature.adFree:
        return 'Reklamsız deneyim için Özel Rehber\'e geçin';
      case PremiumFeature.prioritySupport:
        return 'Öncelikli destek için Özel Rehber\'e geçin';
      case PremiumFeature.exclusiveContent:
        return 'Özel içerikler için Özel Rehber\'e geçin';
    }
  }
}

/// Premium upgrade prompt dialog
Future<bool?> showPremiumUpgradePrompt(
  BuildContext context, {
  required String title,
  required String description,
  String? ctaText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: PremiumColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PremiumSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crown icon with glow
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumColors.premiumGold.withOpacity(0.3),
                    PremiumColors.premiumGold.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.premiumGold.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text('👑', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: PremiumSpacing.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumSpacing.md),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: PremiumSpacing.xl),

            // CTA Button
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PremiumSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumColors.premiumGold,
                      PremiumColors.premiumGoldDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(PremiumRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumColors.premiumGold.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  ctaText ?? 'Özel Rehber\'e Geç',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: PremiumSpacing.md),

            // Cancel button
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Padding(
                padding: const EdgeInsets.all(PremiumSpacing.sm),
                child: Text(
                  'Şimdilik Geç',
                  style: TextStyle(
                    color: PremiumColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Premium badge widget
class PremiumBadge extends StatelessWidget {
  final bool small;

  const PremiumBadge({
    super.key,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? PremiumSpacing.sm : PremiumSpacing.md,
        vertical: small ? 2 : PremiumSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.premiumGold,
            PremiumColors.premiumGoldDark,
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '👑',
            style: TextStyle(fontSize: small ? 10 : 12),
          ),
          SizedBox(width: small ? 2 : PremiumSpacing.xs),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: small ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to conditionally show ads
class AdVisibilityWrapper extends ConsumerWidget {
  final Widget child;
  final Widget adWidget;

  const AdVisibilityWrapper({
    super.key,
    required this.child,
    required this.adWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAds = ref.watch(showAdsProvider);
    final adFrequency = ref.watch(adFrequencyProvider);

    if (!showAds || !adFrequency.canShowAd || adFrequency.dailyLimitReached) {
      return child;
    }

    return Column(
      children: [
        child,
        const SizedBox(height: PremiumSpacing.lg),
        adWidget,
      ],
    );
  }
}
