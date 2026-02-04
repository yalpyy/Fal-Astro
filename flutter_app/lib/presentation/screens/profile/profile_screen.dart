import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../router/route_names.dart';

/// Premium profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final zodiacSign = profileState.birthProfile?.zodiacSign;
    final zodiacLabel = zodiacSign != null ? Formatters.zodiacLabel(zodiacSign) : null;

    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(PremiumSpacing.lg),
          children: [
            // Premium Profile Header
            _PremiumProfileHeader(
              name: profileState.profile?.name ?? 'Kullanıcı',
              avatarUrl: profileState.profile?.avatarUrl,
              zodiacLabel: zodiacLabel,
              isPremium: subscriptionState.isPremium,
              tierName: subscriptionState.tier.displayName,
              onEditTap: () => context.pushNamed(RouteNames.profileEdit),
            ),
            const SizedBox(height: PremiumSpacing.xl),

            // Premium Upgrade Card (if not premium)
            if (!subscriptionState.isPremium) ...[
              _PremiumUpgradeCard(
                onTap: () => context.pushNamed(RouteNames.shop),
              ),
              const SizedBox(height: PremiumSpacing.lg),
            ],

            // Settings Section
            _PremiumSettingsSection(
              title: 'Ayarlar',
              icon: '⚙️',
              children: [
                _PremiumSettingsTile(
                  icon: '🎛️',
                  title: 'Tüm Ayarlar',
                  subtitle: 'Ses, bildirimler, dil',
                  onTap: () => context.pushNamed(RouteNames.settings),
                ),
                _PremiumSettingsTile(
                  icon: '🌓',
                  title: 'Tema',
                  subtitle: _themeModeLabel(themeMode),
                  onTap: () => _showThemeDialog(context, ref),
                ),
                _PremiumSettingsTile(
                  icon: '🌐',
                  title: 'Dil',
                  subtitle: locale.languageCode == 'tr' ? 'Türkçe' : 'English',
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _PremiumSettingsTile(
                  icon: '🔔',
                  title: 'Bildirimler',
                  onTap: () => context.pushNamed(RouteNames.notificationSettings),
                ),
              ],
            ),
            const SizedBox(height: PremiumSpacing.lg),

            // About Section
            _PremiumSettingsSection(
              title: 'Hakkında',
              icon: 'ℹ️',
              children: [
                _PremiumSettingsTile(
                  icon: '🔒',
                  title: 'Gizlilik Politikası',
                  onTap: () => context.pushNamed(RouteNames.privacyPolicy),
                ),
                _PremiumSettingsTile(
                  icon: '📜',
                  title: 'Kullanım Koşulları',
                  onTap: () => context.pushNamed(RouteNames.termsOfService),
                ),
                _PremiumSettingsTile(
                  icon: '✨',
                  title: 'Uygulama Hakkında',
                  subtitle: 'Versiyon 2.0.0',
                  onTap: () => context.pushNamed(RouteNames.about),
                ),
              ],
            ),
            const SizedBox(height: PremiumSpacing.lg),

            // Account Section
            _PremiumSettingsSection(
              title: 'Hesap',
              icon: '👤',
              children: [
                _PremiumSettingsTile(
                  icon: '🚪',
                  title: 'Çıkış Yap',
                  isDestructive: true,
                  onTap: () => _confirmSignOut(context, ref),
                ),
                _PremiumSettingsTile(
                  icon: '🗑️',
                  title: 'Hesabı Sil',
                  isDestructive: true,
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ],
            ),
            const SizedBox(height: PremiumSpacing.xxl),
          ],
        ),
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
      builder: (context) => _PremiumDialog(
        title: 'Tema Seçin',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = ref.read(themeModeProvider) == mode;
            return _PremiumRadioTile(
              title: _themeModeLabel(mode),
              isSelected: isSelected,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
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
      builder: (context) => _PremiumDialog(
        title: 'Dil Seçin',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PremiumRadioTile(
              title: 'Türkçe',
              isSelected: ref.read(localeProvider).languageCode == 'tr',
              onTap: () {
                ref.read(localeProvider.notifier).setTurkish();
                Navigator.pop(context);
              },
            ),
            _PremiumRadioTile(
              title: 'English',
              isSelected: ref.read(localeProvider).languageCode == 'en',
              onTap: () {
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
      builder: (context) => _PremiumDialog(
        title: 'Çıkış Yap',
        content: Text(
          'Çıkış yapmak istediğinizden emin misiniz?',
          style: TextStyle(color: PremiumColors.textSecondary),
        ),
        actions: [
          _PremiumDialogButton(
            label: 'İptal',
            onTap: () => Navigator.pop(context),
          ),
          _PremiumDialogButton(
            label: 'Çıkış Yap',
            isPrimary: true,
            onTap: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _PremiumDialog(
        title: 'Hesabı Sil',
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: PremiumColors.textSecondary),
        ),
        actions: [
          _PremiumDialogButton(
            label: 'İptal',
            onTap: () => Navigator.pop(context),
          ),
          _PremiumDialogButton(
            label: 'Hesabı Sil',
            isDestructive: true,
            onTap: () {
              ref.read(authProvider.notifier).deleteAccount();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Premium profile header with avatar and glow
class _PremiumProfileHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? zodiacLabel;
  final bool isPremium;
  final String tierName;
  final VoidCallback onEditTap;

  const _PremiumProfileHeader({
    required this.name,
    this.avatarUrl,
    this.zodiacLabel,
    required this.isPremium,
    required this.tierName,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
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
        ),
      ),
      child: Column(
        children: [
          // Avatar with glow and edit button
          GestureDetector(
            onTap: onEditTap,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isPremium
                          ? [PremiumColors.premiumGold, PremiumColors.premiumGoldDark]
                          : [PremiumColors.primaryPurple, PremiumColors.accentCyan],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPremium
                            ? PremiumColors.premiumGold.withOpacity(0.4)
                            : PremiumColors.primaryPurple.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: PremiumColors.cardBackground,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? const Text('🌙', style: TextStyle(fontSize: 40))
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(PremiumSpacing.sm),
                    decoration: BoxDecoration(
                      color: PremiumColors.primaryPurple,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumColors.cardBackground,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PremiumSpacing.lg),

          // Name
          Text(
            name,
            style: const TextStyle(
              color: PremiumColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Zodiac label
          if (zodiacLabel != null) ...[
            const SizedBox(height: PremiumSpacing.xs),
            Text(
              zodiacLabel!,
              style: const TextStyle(
                color: PremiumColors.accentCyan,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: PremiumSpacing.md),

          // Subscription badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumSpacing.md,
              vertical: PremiumSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: isPremium
                  ? LinearGradient(
                      colors: [
                        PremiumColors.premiumGold.withOpacity(0.2),
                        PremiumColors.premiumGold.withOpacity(0.1),
                      ],
                    )
                  : null,
              color: isPremium ? null : PremiumColors.surfaceLight,
              borderRadius: BorderRadius.circular(PremiumRadius.full),
              border: Border.all(
                color: isPremium
                    ? PremiumColors.premiumGold.withOpacity(0.3)
                    : PremiumColors.borderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPremium ? '⭐' : '🌟',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: PremiumSpacing.xs),
                Text(
                  tierName,
                  style: TextStyle(
                    color: isPremium
                        ? PremiumColors.premiumGold
                        : PremiumColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium upgrade card
class _PremiumUpgradeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumUpgradeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumColors.premiumGold.withOpacity(0.15),
              PremiumColors.premiumGoldDark.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.premiumGold.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.premiumGold.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.md),
              decoration: BoxDecoration(
                color: PremiumColors.premiumGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(PremiumRadius.lg),
              ),
              child: const Text('👑', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: PremiumSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Özel Rehbere Geç',
                    style: TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PremiumSpacing.xs),
                  Text(
                    'Sınırsız fal, derin analiz, reklamsız deneyim',
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: PremiumColors.premiumGold,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium settings section
class _PremiumSettingsSection extends StatelessWidget {
  final String title;
  final String icon;
  final List<Widget> children;

  const _PremiumSettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PremiumSpacing.lg,
              PremiumSpacing.lg,
              PremiumSpacing.lg,
              PremiumSpacing.sm,
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: PremiumSpacing.sm),
                Text(
                  title,
                  style: const TextStyle(
                    color: PremiumColors.primaryPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: PremiumSpacing.sm),
        ],
      ),
    );
  }
}

/// Premium settings tile
class _PremiumSettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _PremiumSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumSpacing.lg,
          vertical: PremiumSpacing.md,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: PremiumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? PremiumColors.error
                          : PremiumColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: PremiumColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PremiumColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium dialog
class _PremiumDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const _PremiumDialog({
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PremiumColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PremiumSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumSpacing.lg),
            content,
            if (actions != null) ...[
              const SizedBox(height: PremiumSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium radio tile for dialogs
class _PremiumRadioTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumRadioTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PremiumSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? PremiumColors.primaryPurple
                      : PremiumColors.borderSubtle,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: PremiumColors.primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: PremiumSpacing.md),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? PremiumColors.textPrimary
                    : PremiumColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium dialog button
class _PremiumDialogButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _PremiumDialogButton({
    required this.label,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumSpacing.lg,
          vertical: PremiumSpacing.md,
        ),
        margin: const EdgeInsets.only(left: PremiumSpacing.sm),
        decoration: BoxDecoration(
          color: isPrimary
              ? PremiumColors.primaryPurple
              : isDestructive
                  ? PremiumColors.error
                  : PremiumColors.surfaceLight,
          borderRadius: BorderRadius.circular(PremiumRadius.md),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary || isDestructive
                ? Colors.white
                : PremiumColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
