import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../core/services/ad_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

/// Credit packages provider
final creditPackagesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(safeSupabaseClientProvider);
  if (supabase == null) return [];

  final response = await supabase
      .from('credit_packages')
      .select()
      .eq('is_active', true)
      .order('price_usd');

  return List<Map<String, dynamic>>.from(response);
});

/// Premium shop screen for purchasing credits
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(creditPackagesProvider);
    final profileState = ref.watch(profileProvider);
    final currentCredits = profileState.profile?.credits ?? 0;

    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kredi Mağazası',
          style: TextStyle(
            color: PremiumColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: PremiumColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current credits card with gold glow
            _PremiumCreditsCard(credits: currentCredits),
            const SizedBox(height: PremiumSpacing.xl),

            // How credits work
            _HowCreditsWorkCard(),
            const SizedBox(height: PremiumSpacing.xl),

            // Credit packages
            const Text(
              'Kredi Paketleri',
              style: TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumSpacing.lg),

            packagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: PremiumColors.premiumGold,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Hata: $e',
                  style: TextStyle(color: PremiumColors.error),
                ),
              ),
              data: (packages) => Column(
                children: packages.map((pkg) => _PremiumPackageCard(
                  package: pkg,
                  onPurchase: () => _handlePurchase(context, pkg),
                )).toList(),
              ),
            ),

            const SizedBox(height: PremiumSpacing.xl),

            // Watch ads for credits
            _WatchAdCard(
              onTap: () => _showAdRewardDialog(context, ref),
            ),
            const SizedBox(height: PremiumSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, Map<String, dynamic> package) {
    showDialog(
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
              const Text('💎', style: TextStyle(fontSize: 48)),
              const SizedBox(height: PremiumSpacing.lg),
              Text(
                package['name_tr'],
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PremiumSpacing.md),
              Text(
                'Bu paket yakında satın alınabilir olacak.\n\n'
                '${package['credits']} kredi + ${package['bonus_credits']} bonus\n'
                'Fiyat: ${package['price_try']} ₺',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PremiumColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: PremiumSpacing.xl),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(PremiumSpacing.md),
                  decoration: BoxDecoration(
                    color: PremiumColors.primaryPurple,
                    borderRadius: BorderRadius.circular(PremiumRadius.lg),
                  ),
                  child: const Text(
                    'Tamam',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Future<void> _showAdRewardDialog(BuildContext context, WidgetRef ref) async {
    final adService = AdService.instance;

    if (!adService.isRewardedAdReady) {
      showDialog(
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
                const Text('⏳', style: TextStyle(fontSize: 48)),
                const SizedBox(height: PremiumSpacing.lg),
                const Text(
                  'Reklam Hazırlanıyor',
                  style: TextStyle(
                    color: PremiumColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PremiumSpacing.sm),
                Text(
                  'Lütfen birkaç saniye sonra tekrar deneyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PremiumColors.textSecondary),
                ),
                const SizedBox(height: PremiumSpacing.xl),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumSpacing.xl,
                      vertical: PremiumSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumColors.surfaceLight,
                      borderRadius: BorderRadius.circular(PremiumRadius.lg),
                    ),
                    child: const Text(
                      'Tamam',
                      style: TextStyle(color: PremiumColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final shouldWatch = await showDialog<bool>(
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
              Container(
                padding: const EdgeInsets.all(PremiumSpacing.lg),
                decoration: BoxDecoration(
                  color: PremiumColors.primaryPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎬', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: PremiumSpacing.lg),
              const Text(
                'Reklam İzle',
                style: TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PremiumSpacing.md),
              Text(
                'Kısa bir video reklam izleyerek 1 kredi kazanabilirsin!',
                textAlign: TextAlign.center,
                style: TextStyle(color: PremiumColors.textSecondary),
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
                    const Text('💎', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: PremiumSpacing.sm),
                    Text(
                      '+1 Kredi',
                      style: TextStyle(
                        color: PremiumColors.premiumGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PremiumSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(PremiumSpacing.md),
                        decoration: BoxDecoration(
                          color: PremiumColors.surfaceLight,
                          borderRadius: BorderRadius.circular(PremiumRadius.lg),
                        ),
                        child: const Text(
                          'Vazgeç',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: PremiumColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PremiumSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(PremiumSpacing.md),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PremiumColors.primaryPurple,
                              PremiumColors.primaryPurpleDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(PremiumRadius.lg),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, color: Colors.white, size: 20),
                            SizedBox(width: PremiumSpacing.xs),
                            Text(
                              'İzle',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
        ),
      ),
    );

    if (shouldWatch != true || !context.mounted) return;

    final reward = await adService.showRewardedAd();

    if (!context.mounted) return;

    if (reward != null && reward > 0) {
      final supabase = ref.read(safeSupabaseClientProvider);
      if (supabase != null) {
        try {
          await supabase.rpc('add_user_credits', params: {
            'credit_amount': 1,
            'transaction_type': 'ad_reward',
            'description': 'Reklam izleme ödülü',
          });

          ref.invalidate(profileProvider);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Text('💎', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('1 kredi kazandın!'),
                  ],
                ),
                backgroundColor: PremiumColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumRadius.md),
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kredi eklenirken hata: $e'),
                backgroundColor: PremiumColors.error,
              ),
            );
          }
        }
      }
    }
  }
}

/// Premium credits display card
class _PremiumCreditsCard extends StatelessWidget {
  final int credits;

  const _PremiumCreditsCard({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.premiumGold.withOpacity(0.2),
            PremiumColors.premiumGoldDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: PremiumColors.premiumGold.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.premiumGold.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('💎', style: TextStyle(fontSize: 48)),
          const SizedBox(height: PremiumSpacing.md),
          Text(
            'Mevcut Kredin',
            style: TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: PremiumSpacing.xs),
          Text(
            '$credits',
            style: TextStyle(
              color: PremiumColors.premiumGold,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// How credits work card
class _HowCreditsWorkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: PremiumSpacing.sm),
              const Text(
                'Krediler Nasıl Çalışır?',
                style: TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumSpacing.lg),
          _CreditUsageRow(icon: '☕', feature: 'Kahve Falı', credits: 1),
          _CreditUsageRow(icon: '🌙', feature: 'Rüya Yorumu', credits: 1),
          _CreditUsageRow(icon: '💕', feature: 'Burç Uyumu', credits: 3),
          _CreditUsageRow(icon: '✨', feature: 'Astroloji Raporu', credits: 2),
        ],
      ),
    );
  }
}

/// Credit usage row
class _CreditUsageRow extends StatelessWidget {
  final String icon;
  final String feature;
  final int credits;

  const _CreditUsageRow({
    required this.icon,
    required this.feature,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PremiumSpacing.sm),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: PremiumSpacing.md),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumSpacing.md,
              vertical: PremiumSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: PremiumColors.primaryPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(PremiumRadius.full),
            ),
            child: Text(
              '$credits kredi',
              style: const TextStyle(
                color: PremiumColors.primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium package card
class _PremiumPackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onPurchase;

  const _PremiumPackageCard({
    required this.package,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = package['is_popular'] == true;
    final credits = package['credits'] as int;
    final bonusCredits = package['bonus_credits'] as int? ?? 0;
    final totalCredits = credits + bonusCredits;

    return GestureDetector(
      onTap: onPurchase,
      child: Container(
        margin: const EdgeInsets.only(bottom: PremiumSpacing.md),
        decoration: BoxDecoration(
          gradient: isPopular
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumColors.premiumGold.withOpacity(0.15),
                    PremiumColors.premiumGold.withOpacity(0.05),
                  ],
                )
              : null,
          color: isPopular ? null : PremiumColors.cardBackground,
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: isPopular
                ? PremiumColors.premiumGold.withOpacity(0.3)
                : PremiumColors.borderSubtle,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: PremiumColors.premiumGold.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(PremiumSpacing.lg),
              child: Row(
                children: [
                  // Credits display
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isPopular
                          ? PremiumColors.premiumGold.withOpacity(0.2)
                          : PremiumColors.surfaceLight,
                      borderRadius: BorderRadius.circular(PremiumRadius.lg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isPopular ? '👑' : '💎',
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          '$totalCredits',
                          style: TextStyle(
                            color: isPopular
                                ? PremiumColors.premiumGold
                                : PremiumColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PremiumSpacing.lg),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package['name_tr'] ?? '',
                          style: const TextStyle(
                            color: PremiumColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$credits kredi${bonusCredits > 0 ? ' + $bonusCredits bonus!' : ''}',
                          style: TextStyle(
                            color: bonusCredits > 0
                                ? PremiumColors.success
                                : PremiumColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${package['price_try']} ₺',
                        style: TextStyle(
                          color: isPopular
                              ? PremiumColors.premiumGold
                              : PremiumColors.primaryPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${package['price_usd']}',
                        style: TextStyle(
                          color: PremiumColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumSpacing.md,
                    vertical: PremiumSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumColors.premiumGold,
                        PremiumColors.premiumGoldDark,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(PremiumRadius.xl),
                      bottomLeft: Radius.circular(PremiumRadius.md),
                    ),
                  ),
                  child: const Text(
                    'POPÜLER',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

/// Watch ad for credits card
class _WatchAdCard extends StatelessWidget {
  final VoidCallback onTap;

  const _WatchAdCard({required this.onTap});

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
              PremiumColors.accentCyan.withOpacity(0.15),
              PremiumColors.primaryPurple.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.accentCyan.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.md),
              decoration: BoxDecoration(
                color: PremiumColors.accentCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(PremiumRadius.lg),
              ),
              child: const Text('🎬', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: PremiumSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ücretsiz Kredi Kazan!',
                    style: TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Reklam izle, 1 kredi kazan',
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PremiumColors.accentCyan,
            ),
          ],
        ),
      ),
    );
  }
}
