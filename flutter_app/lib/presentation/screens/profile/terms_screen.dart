import 'package:flutter/material.dart';

/// Terms of service screen
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kullanım Koşulları',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Son güncelleme: 1 Şubat 2024',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Important disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fal & Astro uygulaması yalnızca eğlence amaçlıdır. Sunulan yorumlar bilimsel veya tıbbi tavsiye niteliği taşımaz.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              '1. Hizmet Tanımı',
              '''Fal & Astro, yapay zeka destekli kahve falı, rüya yorumu ve astroloji hizmetleri sunan bir mobil uygulamadır.

Uygulamamız şunları sunar:
• Kahve fincanı fotoğraflarından fal yorumlama
• Rüya anlatımlarından yorum ve analiz
• Doğum haritasına dayalı astroloji raporları
• Günlük, haftalık ve aylık burç yorumları
• Burç uyumu (synastry) analizi''',
            ),

            _buildSection(
              context,
              '2. Kullanım Şartları',
              '''Uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:

• 18 yaşından büyük olmalısınız veya ebeveyn izniniz olmalıdır
• Hesabınızın güvenliğinden siz sorumlusunuz
• Yasadışı amaçlarla kullanamazsınız
• Başkalarının haklarını ihlal edemezsiniz
• Sistem güvenliğini tehlikeye atamazsınız''',
            ),

            _buildSection(
              context,
              '3. Kredi Sistemi',
              '''Uygulama içi hizmetler kredi sistemi ile çalışır:

• Her fal/yorum belirli miktarda kredi gerektirir
• Krediler uygulama içi satın alımlarla edinilebilir
• Reklam izleyerek günlük sınırlı kredi kazanılabilir
• Satın alınan krediler iade edilmez
• Kullanılmayan kredilerin süresi dolmaz''',
            ),

            _buildSection(
              context,
              '4. Premium Üyelik',
              '''Premium üyelik avantajları:

• Sınırsız fal ve rüya yorumu
• Öncelikli işlem sırası
• Reklamsız deneyim
• Özel astroloji raporları

Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.''',
            ),

            _buildSection(
              context,
              '5. İçerik ve Sorumluluk',
              '''Yorumlar hakkında önemli bilgiler:

• Tüm yorumlar yapay zeka tarafından üretilir
• Yorumlar eğlence amaçlıdır, tavsiye niteliği taşımaz
• Sağlık, hukuk veya finansal kararlar için profesyonel destek alın
• Yüklenen içerikler moderasyona tabi olabilir''',
            ),

            _buildSection(
              context,
              '6. Fikri Mülkiyet',
              '''Uygulama ve içeriklerin hakları:

• Uygulama ve tasarımı telif hakkı ile korunmaktadır
• Üretilen yorumların ticari kullanım hakkı bize aittir
• Kişisel sosyal medya paylaşımına izin verilir
• Kopyalama ve yeniden dağıtım yasaktır''',
            ),

            _buildSection(
              context,
              '7. Hesap Sonlandırma',
              '''Hesabınız şu durumlarda sonlandırılabilir:

• Kullanım koşullarının ihlali
• Yasadışı faaliyetler
• Sistem güvenliğini tehlikeye atma
• 12 ay boyunca aktif olmama

Hesap silindiğinde tüm verileriniz kalıcı olarak kaldırılır.''',
            ),

            _buildSection(
              context,
              '8. Değişiklikler',
              '''Bu koşullar önceden haber vermeksizin değiştirilebilir. Önemli değişiklikler uygulama içi bildirimle duyurulacaktır.

Uygulamayı kullanmaya devam etmeniz, güncel koşulları kabul ettiğiniz anlamına gelir.''',
            ),

            _buildSection(
              context,
              '9. İletişim',
              '''Sorularınız için:

E-posta: support@falastro.app
Web: www.falastro.app

Bu koşullar Türkiye Cumhuriyeti yasalarına tabidir.''',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
