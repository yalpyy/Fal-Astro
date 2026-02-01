import 'package:flutter/material.dart';
import '../../../../data/models/daily_astro.dart';

/// Daily astro card on home screen
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.secondaryContainer.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: colorScheme.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Günlük Astroloji',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (zodiacLabel != null)
                          Text(
                            zodiacLabel!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: isLoading ? null : onRefresh,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (dailyAstro != null) ...[
                Text(
                  dailyAstro!.content.length > 150
                      ? '${dailyAstro!.content.substring(0, 150)}...'
                      : dailyAstro!.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.mood,
                      label: 'Mod: ${dailyAstro!.moodScore}/10',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.color_lens,
                      label: dailyAstro!.luckyColor,
                    ),
                  ],
                ),
              ] else
                Text(
                  'Günlük yorumunu görmek için tıkla',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
