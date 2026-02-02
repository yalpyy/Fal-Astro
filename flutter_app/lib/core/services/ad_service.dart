import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing Google Mobile Ads
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// Test ad unit IDs (replace with real IDs in production)
  String get _rewardedAdUnitId {
    if (kDebugMode) {
      // Test ad unit IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }
    // Production ad unit IDs - replace with your actual IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Android rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // iOS rewarded
    }
    return '';
  }

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (kIsWeb) return; // Ads not supported on web

    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  /// Load a rewarded ad
  void _loadRewardedAd() {
    if (kIsWeb) return;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Rewarded ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd();
              debugPrint('Ad failed to show: $error');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          debugPrint('Rewarded ad failed to load: $error');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Check if a rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// Show rewarded ad and return the reward amount (or null if failed/cancelled)
  Future<int?> showRewardedAd() async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('Rewarded ad not ready');
      return null;
    }

    int? rewardAmount;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardAmount = reward.amount.toInt();
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    return rewardAmount;
  }

  /// Dispose the service
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
