import 'package:flutter/material.dart';

/// Privacy policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
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
                    Icons.privacy_tip,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gizlilik Politikası',
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

            _buildSection(
              context,
              'Veri Toplama',
              '''Fal & Astro uygulaması, hizmetlerimizi sunabilmek için aşağıdaki verileri toplar:

• E-posta adresi (hesap oluşturma)
• Doğum tarihi ve saati (astroloji hesaplamaları)
• Doğum yeri (astroloji hesaplamaları)
• Fal fotoğrafları (fal yorumlama)
• Rüya metinleri (rüya yorumlama)

Bu veriler yalnızca uygulama içi hizmetler için kullanılır ve üçüncü taraflarla paylaşılmaz.''',
            ),

            _buildSection(
              context,
              'Veri Kullanımı',
              '''Topladığımız veriler şu amaçlarla kullanılır:

• Kişiselleştirilmiş fal ve astroloji yorumları sunmak
• Hesap güvenliğini sağlamak
• Uygulama deneyimini iyileştirmek
• Teknik sorunları çözmek

Verileriniz yapay zeka modelleri tarafından işlenir ancak bu işlem anlık olup veriler saklanmaz.''',
            ),

            _buildSection(
              context,
              'Veri Güvenliği',
              '''Verilerinizin güvenliği bizim için önceliktir:

• Tüm veriler şifreli olarak saklanır
• SSL/TLS ile güvenli iletişim
• Düzenli güvenlik denetimleri
• Erişim kontrollü veritabanları

Row Level Security (RLS) ile yalnızca kendi verilerinize erişebilirsiniz.''',
            ),

            _buildSection(
              context,
              'KVKK ve GDPR Uyumu',
              '''Kişisel Verilerin Korunması Kanunu (KVKK) ve Genel Veri Koruma Yönetmeliği (GDPR) kapsamında haklarınız:

• Verilerinize erişim hakkı
• Verilerinizin düzeltilmesini isteme hakkı
• Verilerinizin silinmesini isteme hakkı
• Veri işlemeye itiraz hakkı
• Veri taşınabilirliği hakkı

Bu haklarınızı kullanmak için uygulama içinden hesabınızı silebilir veya bizimle iletişime geçebilirsiniz.''',
            ),

            _buildSection(
              context,
              'Çerezler ve Analitik',
              '''Uygulamamız şunları kullanabilir:

• Firebase Analytics (anonim kullanım istatistikleri)
• Crash raporlama (hata tespiti)

Bu veriler anonim olarak toplanır ve kişisel bilgilerinizle ilişkilendirilmez.''',
            ),

            _buildSection(
              context,
              'İletişim',
              '''Gizlilik politikamız hakkında sorularınız için:

E-posta: privacy@falastro.app
Adres: İstanbul, Türkiye

Politikamızda yapılacak değişiklikler uygulama üzerinden bildirilecektir.''',
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
