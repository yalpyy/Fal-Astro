import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/premium_theme.dart';
import '../../../providers/auth_provider.dart';

/// Provider for daily affirmation
final dailyAffirmationProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, zodiacSign) async {
  final supabase = ref.read(safeSupabaseClientProvider);
  if (supabase == null) return null;

  final today = DateTime.now().toIso8601String().split('T')[0];

  final response = await supabase
      .from('daily_affirmations')
      .select()
      .eq('date', today)
      .eq('zodiac_sign', zodiacSign.toLowerCase())
      .eq('locale', 'tr')
      .maybeSingle();

  return response;
});

/// Premium daily affirmation card widget
class DailyAffirmationCard extends ConsumerWidget {
  final String? zodiacSign;

  const DailyAffirmationCard({
    super.key,
    this.zodiacSign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (zodiacSign == null) return const SizedBox.shrink();

    final affirmationAsync = ref.watch(dailyAffirmationProvider(zodiacSign!));

    return affirmationAsync.when(
      loading: () => _buildLoadingCard(),
      error: (_, __) => const SizedBox.shrink(),
      data: (affirmation) {
        if (affirmation == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumColors.primaryPurple.withOpacity(0.15),
                PremiumColors.accentCyan.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(PremiumRadius.xl),
            border: Border.all(
              color: PremiumColors.primaryPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PremiumSpacing.lg),
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
                            PremiumColors.primaryPurple.withOpacity(0.3),
                            PremiumColors.accentCyan.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(PremiumRadius.md),
                      ),
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: PremiumSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Günün Mesajı',
                            style: TextStyle(
                              color: PremiumColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getThemeLabel(affirmation['theme']),
                            style: TextStyle(
                              color: PremiumColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumSpacing.lg),

                // Affirmation text
                Text(
                  affirmation['content_text'] ?? '',
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: PremiumSpacing.lg),

                // Lucky info row
                Wrap(
                  spacing: PremiumSpacing.sm,
                  runSpacing: PremiumSpacing.sm,
                  children: [
                    if (affirmation['lucky_number'] != null)
                      _LuckyChip(
                        icon: '🎲',
                        label: '${affirmation['lucky_number']}',
                      ),
                    if (affirmation['lucky_color'] != null)
                      _LuckyChip(
                        icon: '🎨',
                        label: affirmation['lucky_color'],
                      ),
                    if (affirmation['power_crystal'] != null)
                      _LuckyChip(
                        icon: '💎',
                        label: affirmation['power_crystal'],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
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
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PremiumColors.primaryPurple,
            ),
          ),
          const SizedBox(height: PremiumSpacing.sm),
          Text(
            'Günün mesajı yükleniyor...',
            style: TextStyle(
              color: PremiumColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(String? theme) {
    switch (theme) {
      case 'love':
        return 'Aşk';
      case 'career':
        return 'Kariyer';
      case 'health':
        return 'Sağlık';
      case 'spiritual':
        return 'Ruhsal';
      case 'creativity':
        return 'Yaratıcılık';
      case 'relationships':
        return 'İlişkiler';
      default:
        return 'Genel';
    }
  }
}

class _LuckyChip extends StatelessWidget {
  final String icon;
  final String label;

  const _LuckyChip({
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
