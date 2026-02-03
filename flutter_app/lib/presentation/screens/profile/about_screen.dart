import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// About screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '2.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // App icon and name
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fal & Astro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versiyon $appVersion ($buildNumber)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Description
            Text(
              'Yapay zeka destekli kahve falı, rüya yorumu ve kişiselleştirilmiş astroloji uygulaması.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Features
            _buildFeatureCard(
              context,
              Icons.coffee,
              'Kahve Falı',
              'Fincan fotoğrafınızdan detaylı fal yorumu',
            ),
            _buildFeatureCard(
              context,
              Icons.nights_stay,
              'Rüya Yorumu',
              'Rüyalarınızın gizli anlamlarını keşfedin',
            ),
            _buildFeatureCard(
              context,
              Icons.auto_awesome,
              'Astroloji',
              'Kişisel doğum haritası ve burç analizleri',
            ),
            _buildFeatureCard(
              context,
              Icons.favorite,
              'Burç Uyumu',
              'İlişki ve uyum analizleri',
            ),

            const SizedBox(height: 32),

            // Tech stack
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.code,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Teknolojiler',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip(context, 'Flutter'),
                      _buildTechChip(context, 'Supabase'),
                      _buildTechChip(context, 'OpenAI'),
                      _buildTechChip(context, 'Firebase'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact & Links
            ListTile(
              leading: Icon(Icons.email, color: colorScheme.primary),
              title: const Text('Destek'),
              subtitle: const Text('support@falastro.app'),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'support@falastro.app'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('E-posta adresi kopyalandı')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: colorScheme.primary),
              title: const Text('Web Sitesi'),
              subtitle: const Text('www.falastro.app'),
              onTap: () {
                // Would open URL
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: colorScheme.primary),
              title: const Text('Uygulamayı Değerlendir'),
              subtitle: const Text('Bizi desteklemek için puan verin'),
              onTap: () {
                // Would open store page
              },
            ),

            const SizedBox(height: 24),

            // Copyright
            Text(
              ' 2024 Fal & Astro',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tüm hakları saklıdır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildTechChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
