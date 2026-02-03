import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/push_notification_service.dart';

/// Notification preferences state
class NotificationPrefs {
  final bool dailyHoroscope;
  final bool fortuneReminder;
  final bool promotions;
  final bool newFeatures;

  const NotificationPrefs({
    this.dailyHoroscope = true,
    this.fortuneReminder = true,
    this.promotions = true,
    this.newFeatures = true,
  });

  NotificationPrefs copyWith({
    bool? dailyHoroscope,
    bool? fortuneReminder,
    bool? promotions,
    bool? newFeatures,
  }) {
    return NotificationPrefs(
      dailyHoroscope: dailyHoroscope ?? this.dailyHoroscope,
      fortuneReminder: fortuneReminder ?? this.fortuneReminder,
      promotions: promotions ?? this.promotions,
      newFeatures: newFeatures ?? this.newFeatures,
    );
  }
}

/// Notification preferences provider
final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
  return NotificationPrefsNotifier();
});

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs());

  final _notificationService = PushNotificationService.instance;

  Future<void> setDailyHoroscope(bool value) async {
    state = state.copyWith(dailyHoroscope: value);
    if (value) {
      await _notificationService.subscribeToTopic('daily_horoscope');
    } else {
      await _notificationService.unsubscribeFromTopic('daily_horoscope');
    }
  }

  Future<void> setFortuneReminder(bool value) async {
    state = state.copyWith(fortuneReminder: value);
    if (value) {
      await _notificationService.subscribeToTopic('fortune_reminder');
    } else {
      await _notificationService.unsubscribeFromTopic('fortune_reminder');
    }
  }

  Future<void> setPromotions(bool value) async {
    state = state.copyWith(promotions: value);
    if (value) {
      await _notificationService.subscribeToTopic('promotions');
    } else {
      await _notificationService.unsubscribeFromTopic('promotions');
    }
  }

  Future<void> setNewFeatures(bool value) async {
    state = state.copyWith(newFeatures: value);
    if (value) {
      await _notificationService.subscribeToTopic('new_features');
    } else {
      await _notificationService.unsubscribeFromTopic('new_features');
    }
  }
}

/// Notification settings screen
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bildirim Tercihleri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hangi bildirimlerden haberdar olmak istediğinizi seçin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Divider(),

          // Notification toggles
          _NotificationTile(
            icon: Icons.wb_sunny,
            title: 'Günlük Burç Yorumu',
            subtitle: 'Her gün burcunuzun yorumunu alın',
            value: prefs.dailyHoroscope,
            onChanged: (value) {
              ref.read(notificationPrefsProvider.notifier).setDailyHoroscope(value);
            },
          ),

          _NotificationTile(
            icon: Icons.coffee,
            title: 'Fal Hatırlatıcısı',
            subtitle: 'Günlük fal bakma hatırlatması',
            value: prefs.fortuneReminder,
            onChanged: (value) {
              ref.read(notificationPrefsProvider.notifier).setFortuneReminder(value);
            },
          ),

          _NotificationTile(
            icon: Icons.local_offer,
            title: 'Promosyonlar',
            subtitle: 'Özel indirim ve kampanyalar',
            value: prefs.promotions,
            onChanged: (value) {
              ref.read(notificationPrefsProvider.notifier).setPromotions(value);
            },
          ),

          _NotificationTile(
            icon: Icons.new_releases,
            title: 'Yeni Özellikler',
            subtitle: 'Uygulama güncellemeleri ve yenilikler',
            value: prefs.newFeatures,
            onChanged: (value) {
              ref.read(notificationPrefsProvider.notifier).setNewFeatures(value);
            },
          ),

          const SizedBox(height: 24),

          // Info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sistem bildirimlerini cihaz ayarlarından da yönetebilirsiniz.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
