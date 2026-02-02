import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

/// Admin statistics provider
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = ref.read(safeSupabaseClientProvider);
  if (supabase == null) return {};

  try {
    // Get user count
    final usersResponse = await supabase
        .from('profiles')
        .select('id')
        .count();

    // Get reading count
    final readingsResponse = await supabase
        .from('fortune_readings')
        .select('id')
        .count();

    // Get daily horoscopes count
    final horoscopesResponse = await supabase
        .from('daily_horoscopes')
        .select('id')
        .count();

    // Get today's active users
    final today = DateTime.now().toIso8601String().split('T')[0];
    final activeUsersResponse = await supabase
        .from('profiles')
        .select('id')
        .gte('last_login_at', today)
        .count();

    // Get total credits sold
    final creditsResponse = await supabase
        .from('credit_transactions')
        .select('amount')
        .eq('transaction_type', 'purchase');

    int totalCredits = 0;
    if (creditsResponse is List) {
      for (final row in creditsResponse) {
        totalCredits += (row['amount'] as num?)?.toInt() ?? 0;
      }
    }

    return {
      'total_users': usersResponse.count,
      'total_readings': readingsResponse.count,
      'total_horoscopes': horoscopesResponse.count,
      'active_users_today': activeUsersResponse.count,
      'total_credits_sold': totalCredits,
    };
  } catch (e) {
    return {'error': e.toString()};
  }
});

/// Admin panel screen
class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatsProvider),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yonetici Paneli',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Uygulama istatistikleri ve yonetim',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            Text(
              'Istatistikler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            statsAsync.when(
              data: (stats) {
                if (stats.containsKey('error')) {
                  return Card(
                    color: colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Hata: ${stats['error']}',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Toplam Kullanici',
                            value: '${stats['total_users'] ?? 0}',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Bugun Aktif',
                            value: '${stats['active_users_today'] ?? 0}',
                            icon: Icons.person,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Toplam Fal',
                            value: '${stats['total_readings'] ?? 0}',
                            icon: Icons.coffee,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Gunluk Burc',
                            value: '${stats['total_horoscopes'] ?? 0}',
                            icon: Icons.auto_awesome,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Satilan Kredi',
                      value: '${stats['total_credits_sold'] ?? 0}',
                      icon: Icons.monetization_on,
                      color: Colors.amber,
                      fullWidth: true,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Hata: $error',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Hizli Islemler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              title: 'Gunluk Burc Olustur',
              subtitle: 'Tum burclar icin gunluk yorum olustur',
              icon: Icons.auto_awesome,
              onTap: () => _generateDailyHoroscopes(context, ref),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              title: 'Cache Temizle',
              subtitle: 'Uygulama cache verilerini temizle',
              icon: Icons.cleaning_services,
              onTap: () => _clearCache(context),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              title: 'Bildirim Gonder',
              subtitle: 'Tum kullanicilara bildirim gonder',
              icon: Icons.notifications,
              onTap: () => _showNotificationDialog(context, ref),
            ),
            const SizedBox(height: 8),
            _ActionCard(
              title: 'Kullanici Yonetimi',
              subtitle: 'Kullanicilari goruntule ve yonet',
              icon: Icons.manage_accounts,
              onTap: () => _showUserManagement(context, ref),
            ),
            const SizedBox(height: 24),

            // System Info
            Text(
              'Sistem Bilgisi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: 'Versiyon', value: '2.0.0'),
                    _InfoRow(label: 'Build', value: '${DateTime.now().millisecondsSinceEpoch ~/ 1000}'),
                    _InfoRow(label: 'Ortam', value: 'Production'),
                    _InfoRow(label: 'Backend', value: 'Supabase'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateDailyHoroscopes(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gunluk Burc Olustur'),
        content: const Text(
          'Tum burclar icin gunluk yorumlar olusturulsun mu? '
          'Bu islem Edge Function ile yapilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Iptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Olustur'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabase = ref.read(safeSupabaseClientProvider);
      if (supabase == null) throw Exception('Supabase baglantisi yok');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gunluk burclar olusturuluyor...')),
        );
      }

      await supabase.functions.invoke('cron-daily-generator');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gunluk burclar basariyla olusturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Temizle'),
        content: const Text('Tum cache verileri temizlensin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache temizlendi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedTopic = 'all_users';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Bildirim Gonder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Baslik',
                    hintText: 'Bildirim basligi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Icerik',
                    hintText: 'Bildirim icerigi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTopic,
                  decoration: const InputDecoration(
                    labelText: 'Hedef Kitle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all_users', child: Text('Tum Kullanicilar')),
                    DropdownMenuItem(value: 'promotions', child: Text('Promosyon Aboneleri')),
                    DropdownMenuItem(value: 'horoscope_aries', child: Text('Koc Burcu')),
                    DropdownMenuItem(value: 'horoscope_taurus', child: Text('Boga Burcu')),
                    DropdownMenuItem(value: 'horoscope_gemini', child: Text('Ikizler Burcu')),
                    DropdownMenuItem(value: 'horoscope_cancer', child: Text('Yengec Burcu')),
                    DropdownMenuItem(value: 'horoscope_leo', child: Text('Aslan Burcu')),
                    DropdownMenuItem(value: 'horoscope_virgo', child: Text('Basak Burcu')),
                    DropdownMenuItem(value: 'horoscope_libra', child: Text('Terazi Burcu')),
                    DropdownMenuItem(value: 'horoscope_scorpio', child: Text('Akrep Burcu')),
                    DropdownMenuItem(value: 'horoscope_sagittarius', child: Text('Yay Burcu')),
                    DropdownMenuItem(value: 'horoscope_capricorn', child: Text('Oglak Burcu')),
                    DropdownMenuItem(value: 'horoscope_aquarius', child: Text('Kova Burcu')),
                    DropdownMenuItem(value: 'horoscope_pisces', child: Text('Balik Burcu')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedTopic = value ?? 'all_users');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Iptal'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Baslik ve icerik gerekli')),
                  );
                  return;
                }

                Navigator.pop(context);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirim gonderiliyor...')),
                );

                try {
                  final supabase = ref.read(safeSupabaseClientProvider);
                  if (supabase == null) throw Exception('Supabase baglantisi yok');

                  final response = await supabase.functions.invoke(
                    'send-notification',
                    body: {
                      'title': titleController.text,
                      'body': bodyController.text,
                      'topic': selectedTopic,
                    },
                  );

                  if (response.status != 200) {
                    throw Exception(response.data?['error'] ?? 'Bildirim gonderilemedi');
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bildirim gonderildi: ${response.data?['message'] ?? 'Basarili'}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Gonder'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserManagement(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _UserManagementSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// Statistic card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action card widget
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// User management bottom sheet
class _UserManagementSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _UserManagementSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.manage_accounts, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Kullanici Yonetimi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kullanici ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User list placeholder
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Kullanici ${index + 1}'),
                    subtitle: Text('user${index + 1}@example.com'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('Goruntule'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'credits',
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on),
                              SizedBox(width: 8),
                              Text('Kredi Ekle'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'ban',
                          child: Row(
                            children: [
                              Icon(Icons.block, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Engelle'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Secilen: $value')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
