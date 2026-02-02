import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';

/// Provider for daily affirmation
final dailyAffirmationProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, zodiacSign) async {
  final supabase = ref.read(supabaseServiceProvider);
  final today = DateTime.now().toIso8601String().split('T')[0];

  final response = await supabase.client
      .from('daily_affirmations')
      .select()
      .eq('date', today)
      .eq('zodiac_sign', zodiacSign.toLowerCase())
      .eq('locale', 'tr')
      .maybeSingle();

  return response;
});

/// Daily affirmation card widget
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
    final colorScheme = Theme.of(context).colorScheme;

    return affirmationAsync.when(
      loading: () => _buildLoadingCard(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (affirmation) {
        if (affirmation == null) return const SizedBox.shrink();

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Günün Mesajı',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              _getThemeLabel(affirmation['theme']),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Affirmation text
                  Text(
                    affirmation['content_text'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Lucky info row
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (affirmation['lucky_number'] != null)
                        _LuckyChip(
                          icon: Icons.casino,
                          label: '${affirmation['lucky_number']}',
                          tooltip: 'Şanslı Sayı',
                        ),
                      if (affirmation['lucky_color'] != null)
                        _LuckyChip(
                          icon: Icons.palette,
                          label: affirmation['lucky_color'],
                          tooltip: 'Şanslı Renk',
                        ),
                      if (affirmation['power_crystal'] != null)
                        _LuckyChip(
                          icon: Icons.diamond,
                          label: affirmation['power_crystal'],
                          tooltip: 'Güç Kristali',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'Günün mesajı yükleniyor...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(String? theme) {
    switch (theme) {
      case 'love':
        return '💕 Aşk';
      case 'career':
        return '💼 Kariyer';
      case 'health':
        return '🌿 Sağlık';
      case 'spiritual':
        return '🔮 Ruhsal';
      case 'creativity':
        return '🎨 Yaratıcılık';
      case 'relationships':
        return '👥 İlişkiler';
      default:
        return '✨ Genel';
    }
  }
}

class _LuckyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _LuckyChip({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
