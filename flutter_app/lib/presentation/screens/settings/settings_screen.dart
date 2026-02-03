import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/locale_provider.dart';
import '../../router/route_names.dart';

/// System settings state
class SystemSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;

  const SystemSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  SystemSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return SystemSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

/// Notification settings state
class NotificationSettings {
  final bool fortuneNotifications;
  final bool campaignNotifications;

  const NotificationSettings({
    this.fortuneNotifications = true,
    this.campaignNotifications = true,
  });

  NotificationSettings copyWith({
    bool? fortuneNotifications,
    bool? campaignNotifications,
  }) {
    return NotificationSettings(
      fortuneNotifications: fortuneNotifications ?? this.fortuneNotifications,
      campaignNotifications: campaignNotifications ?? this.campaignNotifications,
    );
  }
}

/// System settings provider
final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier();
});

class SystemSettingsNotifier extends StateNotifier<SystemSettings> {
  SystemSettingsNotifier() : super(const SystemSettings());

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void setVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    if (value) {
      HapticFeedback.mediumImpact();
    }
  }
}

/// Notification settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());

  void setFortuneNotifications(bool value) {
    state = state.copyWith(fortuneNotifications: value);
  }

  void setCampaignNotifications(bool value) {
    state = state.copyWith(campaignNotifications: value);
  }
}

/// Settings screen with dark theme
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemSettings = ref.watch(systemSettingsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            _buildHeader(context),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Ayarlar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sistem section
                    _buildSectionTitle('Sistem'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _SettingsToggleItem(
                        icon: Icons.volume_up,
                        iconColor: const Color(0xFF4A9DFF),
                        title: 'Ses',
                        value: systemSettings.soundEnabled,
                        onChanged: (value) {
                          ref.read(systemSettingsProvider.notifier).setSoundEnabled(value);
                        },
                      ),
                      _SettingsToggleItem(
                        icon: Icons.vibration,
                        iconColor: const Color(0xFFFF9500),
                        title: 'Titreşim',
                        value: systemSettings.vibrationEnabled,
                        onChanged: (value) {
                          ref.read(systemSettingsProvider.notifier).setVibrationEnabled(value);
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Bildirimler section
                    _buildSectionTitle('Bildirimler'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _SettingsToggleItem(
                        icon: Icons.description,
                        iconColor: const Color(0xFFFF6B6B),
                        title: 'Fal Bildirimleri',
                        value: notificationSettings.fortuneNotifications,
                        onChanged: (value) {
                          ref.read(notificationSettingsProvider.notifier).setFortuneNotifications(value);
                        },
                      ),
                      _SettingsToggleItem(
                        icon: Icons.campaign,
                        iconColor: const Color(0xFFFF9500),
                        title: 'Kampanya ve İndirimler',
                        value: notificationSettings.campaignNotifications,
                        onChanged: (value) {
                          ref.read(notificationSettingsProvider.notifier).setCampaignNotifications(value);
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Bizi Değerlendir section
                    _buildSectionTitle('Bizi Değerlendir'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _SettingsNavigationItem(
                        icon: Icons.star,
                        iconColor: const Color(0xFFFFD700),
                        title: 'Bizi Değerlendir',
                        onTap: () => _rateApp(),
                      ),
                      _SettingsNavigationItem(
                        icon: Icons.chat_bubble,
                        iconColor: const Color(0xFF4A9DFF),
                        title: 'Bize Yazın',
                        onTap: () => _contactUs(),
                      ),
                      _SettingsNavigationItem(
                        icon: Icons.account_balance,
                        iconColor: const Color(0xFF4ADE80),
                        title: 'Kredi Geçmişi',
                        onTap: () => context.pushNamed(RouteNames.creditHistory),
                      ),
                      _SettingsNavigationItem(
                        icon: Icons.workspace_premium,
                        iconColor: const Color(0xFFFFD700),
                        title: 'Premium Ol!',
                        isEmoji: true,
                        onTap: () => context.pushNamed(RouteNames.shop),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Diller section
                    _buildSectionTitle('Diller'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _SettingsNavigationItem(
                        icon: Icons.language,
                        iconColor: const Color(0xFF4A9DFF),
                        title: 'Dil',
                        subtitle: locale.languageCode == 'tr' ? 'Türkçe' : 'English',
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Yasal section
                    _buildSectionTitle('Yasal'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _SettingsNavigationItem(
                        icon: Icons.privacy_tip,
                        iconColor: const Color(0xFF9B59B6),
                        title: 'Gizlilik Politikası',
                        onTap: () => context.pushNamed(RouteNames.privacyPolicy),
                      ),
                      _SettingsNavigationItem(
                        icon: Icons.description,
                        iconColor: const Color(0xFF3498DB),
                        title: 'Kullanım Koşulları',
                        onTap: () => context.pushNamed(RouteNames.termsOfService),
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Version
                    Center(
                      child: Text(
                        'Versiyon 2.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Future<void> _rateApp() async {
    // Try to open app store
    const appStoreUrl = 'https://apps.apple.com/app/idXXXXXXXX';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.falastro.app';

    try {
      // For now, just share the app
      await Share.share(
        'Fal & Astro uygulamasını deneyin! 🔮✨',
        subject: 'Fal & Astro',
      );
    } catch (e) {
      debugPrint('Could not launch store: $e');
    }
  }

  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'destek@falastro.com',
      queryParameters: {
        'subject': 'Fal & Astro Uygulama Desteği',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dil Seçin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _LanguageOption(
                flag: '🇹🇷',
                name: 'Türkçe',
                isSelected: ref.read(localeProvider).languageCode == 'tr',
                onTap: () {
                  ref.read(localeProvider.notifier).setTurkish();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _LanguageOption(
                flag: '🇬🇧',
                name: 'English',
                isSelected: ref.read(localeProvider).languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).setEnglish();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

/// Toggle item for settings
class _SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4ADE80),
            activeTrackColor: const Color(0xFF4ADE80).withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

/// Navigation item for settings
class _SettingsNavigationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isEmoji;

  const _SettingsNavigationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (isEmoji)
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text('👑', style: const TextStyle(fontSize: 24)),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Language option widget
class _LanguageOption extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A9DFF).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A9DFF)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4A9DFF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
