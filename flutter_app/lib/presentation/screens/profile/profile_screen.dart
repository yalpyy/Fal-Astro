import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/route_names.dart';

/// Profile and settings screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final zodiacSign = profileState.birthProfile?.zodiacSign;
    final zodiacLabel = zodiacSign != null ? Formatters.zodiacLabel(zodiacSign) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile avatar with edit button
                GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.profileEdit),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: profileState.profile?.avatarUrl != null
                            ? NetworkImage(profileState.profile!.avatarUrl!)
                            : null,
                        child: profileState.profile?.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 48,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: colorScheme.onPrimary,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profileState.profile?.name ?? 'Kullanıcı',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (zodiacLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    zodiacLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                // Subscription badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: subscriptionState.isPremium
                        ? Colors.amber.shade100
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subscriptionState.tier.displayName,
                    style: TextStyle(
                      color: subscriptionState.isPremium
                          ? Colors.amber.shade900
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Settings
          _SettingsSection(
            title: 'Ayarlar',
            children: [
              // All Settings
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Tüm Ayarlar'),
                subtitle: const Text('Ses, bildirimler, dil ve daha fazlası'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.settings),
              ),

              // Theme
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Tema'),
                subtitle: Text(_themeModeLabel(themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref),
              ),

              // Language
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Dil'),
                subtitle: Text(locale.languageCode == 'tr' ? 'Türkçe' : 'English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, ref),
              ),

              // Notifications
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Bildirimler'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.notificationSettings),
              ),
            ],
          ),

          // Premium
          if (!subscriptionState.isPremium)
            _SettingsSection(
              title: 'Premium',
              children: [
                ListTile(
                  leading: Icon(Icons.workspace_premium, color: Colors.amber.shade700),
                  title: const Text('Premium\'a Geç'),
                  subtitle: const Text('Sınırsız fal ve rapor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(RouteNames.shop),
                ),
              ],
            ),

          // About
          _SettingsSection(
            title: 'Hakkında',
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Gizlilik Politikası'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.privacyPolicy),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Kullanım Koşulları'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.termsOfService),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Uygulama Hakkında'),
                subtitle: const Text('Versiyon 2.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.about),
              ),
            ],
          ),

          // Account
          _SettingsSection(
            title: 'Hesap',
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(
                  'Çıkış Yap',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () => _confirmSignOut(context, ref),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: colorScheme.error),
                title: Text(
                  'Hesabı Sil',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistem';
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              value: mode,
              groupValue: ref.read(themeModeProvider),
              title: Text(_themeModeLabel(mode)),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'tr',
              groupValue: ref.read(localeProvider).languageCode,
              title: const Text('Türkçe'),
              onChanged: (value) {
                ref.read(localeProvider.notifier).setTurkish();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: ref.read(localeProvider).languageCode,
              title: const Text('English'),
              onChanged: (value) {
                ref.read(localeProvider.notifier).setEnglish();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(authProvider.notifier).deleteAccount();
              Navigator.pop(context);
            },
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}
