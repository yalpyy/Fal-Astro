import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/fortune_reading.dart';
import '../../providers/fortune_provider.dart';
import '../../widgets/common/disclaimer_banner.dart';

/// Fortune result screen
class FortuneResultScreen extends ConsumerWidget {
  final String readingId;

  const FortuneResultScreen({super.key, required this.readingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(fortuneReadingProvider(readingId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fal Sonucu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share functionality
            },
          ),
        ],
      ),
      body: readingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hata: $error')),
        data: (reading) {
          if (reading == null) {
            return const Center(child: Text('Fal bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _intentColor(reading.intent).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        Formatters.intentLabel(reading.intent.name),
                        style: TextStyle(
                          color: _intentColor(reading.intent),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      reading.createdAt.toString().substring(0, 10),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Result text
                Text(
                  'Yorumunuz',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  reading.resultText ?? 'Yorum bulunamadı',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Timelines
                if (reading.timelines != null) ...[
                  Text(
                    'Zaman Çizelgesi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _TimelineCard(
                    title: '7 Gün İçinde',
                    content: reading.timelines!.near,
                    icon: Icons.looks_one,
                    color: Colors.green,
                  ),
                  _TimelineCard(
                    title: '1 Ay İçinde',
                    content: reading.timelines!.mid,
                    icon: Icons.looks_two,
                    color: Colors.orange,
                  ),
                  _TimelineCard(
                    title: '3 Ay İçinde',
                    content: reading.timelines!.far,
                    icon: Icons.looks_3,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),
                ],

                // Symbols
                if (reading.symbols.isNotEmpty) ...[
                  Text(
                    'Semboller',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reading.symbols.map((symbol) {
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            '${(symbol.confidence * 100).round()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              symbol.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              symbol.meaning,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Disclaimer
                const DisclaimerBanner(),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _intentColor(FortuneIntent intent) {
    switch (intent) {
      case FortuneIntent.love:
        return Colors.pink;
      case FortuneIntent.money:
        return Colors.green;
      case FortuneIntent.career:
        return Colors.blue;
      case FortuneIntent.general:
        return Colors.purple;
    }
  }
}

class _TimelineCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _TimelineCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
