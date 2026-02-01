import 'package:equatable/equatable.dart';

/// Subscription provider
enum SubscriptionProvider {
  apple,
  google,
  manual;

  static SubscriptionProvider fromString(String value) {
    return SubscriptionProvider.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SubscriptionProvider.manual,
    );
  }
}

/// Subscription status
enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
  trial;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SubscriptionStatus.inactive,
    );
  }
}

/// Subscription tier
enum SubscriptionTier {
  free,
  premium,
  premiumPlus;

  static SubscriptionTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'premium_plus':
      case 'premiumplus':
        return SubscriptionTier.premiumPlus;
      default:
        return SubscriptionTier.free;
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Ücretsiz';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.premiumPlus:
        return 'Premium+';
    }
  }
}

/// Subscription model
class Subscription extends Equatable {
  final String userId;
  final SubscriptionProvider provider;
  final String? productId;
  final SubscriptionStatus status;
  final SubscriptionTier tier;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? trialEndsAt;
  final DateTime updatedAt;

  const Subscription({
    required this.userId,
    this.provider = SubscriptionProvider.manual,
    this.productId,
    this.status = SubscriptionStatus.inactive,
    this.tier = SubscriptionTier.free,
    this.startsAt,
    this.expiresAt,
    this.trialEndsAt,
    required this.updatedAt,
  });

  /// Check if subscription is active
  bool get isActive {
    if (status != SubscriptionStatus.active) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }

  /// Check if user is premium
  bool get isPremium =>
      isActive && (tier == SubscriptionTier.premium || tier == SubscriptionTier.premiumPlus);

  /// Check if trial is active
  bool get isTrialActive {
    if (status != SubscriptionStatus.trial) return false;
    if (trialEndsAt != null && trialEndsAt!.isBefore(DateTime.now())) return false;
    return true;
  }

  /// Days remaining
  int? get daysRemaining {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.inDays;
  }

  /// Create free tier subscription
  factory Subscription.free(String userId) {
    return Subscription(
      userId: userId,
      provider: SubscriptionProvider.manual,
      status: SubscriptionStatus.active,
      tier: SubscriptionTier.free,
      updatedAt: DateTime.now(),
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['user_id'] as String,
      provider: SubscriptionProvider.fromString(json['provider'] as String? ?? 'manual'),
      productId: json['product_id'] as String?,
      status: SubscriptionStatus.fromString(json['status'] as String? ?? 'inactive'),
      tier: SubscriptionTier.fromString(json['tier'] as String? ?? 'free'),
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'provider': provider.name,
      'product_id': productId,
      'status': status.name,
      'tier': tier.name,
      'starts_at': startsAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        provider,
        productId,
        status,
        tier,
        startsAt,
        expiresAt,
        trialEndsAt,
      ];
}
