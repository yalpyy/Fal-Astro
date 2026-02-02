import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ad_service.dart';

/// Provider for ad service instance
final adServiceProvider = Provider<AdService>((ref) {
  return AdService.instance;
});

/// Provider for checking if rewarded ad is ready
final isRewardedAdReadyProvider = StateProvider<bool>((ref) {
  return AdService.instance.isRewardedAdReady;
});

/// Provider for watching rewarded ad and earning credits
final watchAdForCreditsProvider = FutureProvider.family<int?, void>((ref, _) async {
  final adService = ref.read(adServiceProvider);

  // Show the ad and get reward
  final reward = await adService.showRewardedAd();

  // Refresh the ad ready state
  ref.invalidate(isRewardedAdReadyProvider);

  return reward;
});
