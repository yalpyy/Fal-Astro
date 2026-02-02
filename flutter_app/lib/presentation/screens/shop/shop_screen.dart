import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Shop screen for purchasing credits
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(creditPackagesProvider);
    final profileState = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final currentCredits = profileState.profile?.credits ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kredi Mağazası'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current credits card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mevcut Kredin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentCredits',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // How credits work
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Krediler Nasıl Çalışır?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _CreditUsageRow(
                      icon: Icons.coffee,
                      feature: 'Kahve Falı',
                      credits: 1,
                    ),
                    _CreditUsageRow(
                      icon: Icons.nightlight_round,
                      feature: 'Rüya Yorumu',
                      credits: 1,
                    ),
                    _CreditUsageRow(
                      icon: Icons.favorite,
                      feature: 'Burç Uyumu',
                      credits: 3,
                    ),
                    _CreditUsageRow(
                      icon: Icons.auto_awesome,
                      feature: 'Astroloji Raporu',
                      credits: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Credit packages
            Text(
              'Kredi Paketleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            packagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Hata: $e'),
              ),
              data: (packages) => Column(
                children: packages.map((pkg) => _CreditPackageCard(
                  package: pkg,
                  onPurchase: () => _handlePurchase(context, pkg),
                )).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Watch ads for credits
            Card(
              color: colorScheme.tertiaryContainer,
              child: InkWell(
                onTap: () => _showAdRewardDialog(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.play_circle_filled,
                          color: colorScheme.tertiary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ücretsiz Kredi Kazan!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                            ),
                            Text(
                              'Reklam izle, 1 kredi kazan',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(package['name_tr']),
        content: Text(
          'Bu paket yakında satın alınabilir olacak.\n\n'
          '${package['credits']} kredi + ${package['bonus_credits']} bonus\n'
          'Fiyat: ${package['price_try']} ₺',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdRewardDialog(BuildContext context, WidgetRef ref) async {
    final adService = AdService.instance;

    if (!adService.isRewardedAdReady) {
      // Ad not ready, show message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reklam Hazırlanıyor'),
          content: const Text(
            'Reklam yükleniyor, lütfen birkaç saniye sonra tekrar deneyin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldWatch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.play_circle_filled, size: 48),
        title: const Text('Reklam İzle'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kısa bir video reklam izleyerek 1 kredi kazanabilirsin!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '+1 Kredi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_arrow),
            label: const Text('İzle'),
          ),
        ],
      ),
    );

    if (shouldWatch != true || !context.mounted) return;

    // Show the ad
    final reward = await adService.showRewardedAd();

    if (!context.mounted) return;

    if (reward != null && reward > 0) {
      // Add credits to user's account
      final supabase = ref.read(safeSupabaseClientProvider);
      if (supabase != null) {
        try {
          // Call RPC to add credits
          await supabase.rpc('add_user_credits', params: {
            'credit_amount': 1,
            'transaction_type': 'ad_reward',
            'description': 'Reklam izleme ödülü',
          });

          // Refresh profile to update credits
          ref.invalidate(profileProvider);

          // Show success
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('1 kredi kazandın!'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kredi eklenirken hata: $e')),
            );
          }
        }
      }
    } else {
      // Ad was cancelled or failed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam tamamlanmadı, kredi verilmedi.'),
          ),
        );
      }
    }
  }
}

class _CreditUsageRow extends StatelessWidget {
  final IconData icon;
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(feature)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$credits kredi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditPackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onPurchase;

  const _CreditPackageCard({
    required this.package,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPopular = package['is_popular'] == true;
    final credits = package['credits'] as int;
    final bonusCredits = package['bonus_credits'] as int? ?? 0;
    final totalCredits = credits + bonusCredits;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          InkWell(
            onTap: onPurchase,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Credits icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isPopular
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: isPopular ? colorScheme.primary : Colors.grey,
                        ),
                        Text(
                          '$totalCredits',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isPopular ? colorScheme.primary : null,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package['name_tr'] ?? '',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '$credits kredi${bonusCredits > 0 ? ' + $bonusCredits bonus!' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: bonusCredits > 0 ? Colors.green : null,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      Text(
                        '\$${package['price_usd']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'POPÜLER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
