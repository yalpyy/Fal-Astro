import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/failures.dart';
import '../models/subscription.dart';

/// Subscription repository
class SubscriptionRepository {
  final SupabaseClient _client;

  SubscriptionRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Get current subscription
  Future<Subscription> getSubscription() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.subscriptionsTable)
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) {
        // Return free tier if no subscription exists
        return Subscription.free(_userId!);
      }

      return Subscription.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get subscription: ${e.message}');
    }
  }

  /// Check if user is premium
  Future<bool> isPremium() async {
    final subscription = await getSubscription();
    return subscription.isPremium;
  }

  /// Check if user has active trial
  Future<bool> hasActiveTrial() async {
    final subscription = await getSubscription();
    return subscription.isTrialActive;
  }

  /// Verify and update subscription from store receipt
  /// NOTE: This is a stub - actual implementation would validate with App Store/Google Play
  Future<Subscription> verifyPurchase({
    required SubscriptionProvider provider,
    required String productId,
    required String receiptData,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    // TODO: Implement actual receipt validation
    // This would typically:
    // 1. Call a server-side function to validate the receipt
    // 2. Update the subscription in the database
    // 3. Return the updated subscription

    // For now, just return current subscription
    return getSubscription();
  }

  /// Start a free trial
  /// NOTE: This is a stub - actual implementation would be more robust
  Future<Subscription> startTrial() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final trialEnds = DateTime.now().add(const Duration(days: 7));

      final response = await _client
          .from(SupabaseConstants.subscriptionsTable)
          .update({
            'status': 'trial',
            'tier': 'premium',
            'trial_ends_at': trialEnds.toIso8601String(),
          })
          .eq('user_id', _userId!)
          .select()
          .single();

      return Subscription.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to start trial: ${e.message}');
    }
  }

  /// Cancel subscription
  /// NOTE: This is a stub - actual cancellation would be handled by store
  Future<Subscription> cancelSubscription() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.subscriptionsTable)
          .update({
            'status': 'cancelled',
          })
          .eq('user_id', _userId!)
          .select()
          .single();

      return Subscription.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to cancel subscription: ${e.message}');
    }
  }

  /// Restore purchases
  /// NOTE: This is a stub - actual implementation would query store
  Future<Subscription> restorePurchases() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    // TODO: Implement actual restore logic
    // This would:
    // 1. Query App Store/Google Play for past purchases
    // 2. Validate each purchase
    // 3. Update subscription if valid purchase found

    return getSubscription();
  }
}
