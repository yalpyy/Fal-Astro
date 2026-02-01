import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';
import 'auth_provider.dart';

/// Subscription repository provider - returns null if Supabase not configured
final subscriptionRepositoryProvider = Provider<SubscriptionRepository?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  if (client == null) return null;
  return SubscriptionRepository(client);
});

/// Subscription state
class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isPremium => subscription?.isPremium ?? false;
  bool get isFreeTier => subscription?.tier == SubscriptionTier.free;
  SubscriptionTier get tier => subscription?.tier ?? SubscriptionTier.free;
}

/// Subscription notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository? _repository;

  SubscriptionNotifier(this._repository) : super(const SubscriptionState());

  Future<void> loadSubscription() async {
    if (_repository == null) {
      // Unconfigured - no subscription to load
      state = const SubscriptionState(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscription = await _repository.getSubscription();
      state = SubscriptionState(subscription: subscription);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startTrial() async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscription = await _repository.startTrial();
      state = SubscriptionState(subscription: subscription);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyPurchase({
    required SubscriptionProvider provider,
    required String productId,
    required String receiptData,
  }) async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscription = await _repository.verifyPurchase(
        provider: provider,
        productId: productId,
        receiptData: receiptData,
      );
      state = SubscriptionState(subscription: subscription);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final subscription = await _repository.restorePurchases();
      state = SubscriptionState(subscription: subscription);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const SubscriptionState();
  }
}

/// Subscription provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final notifier = SubscriptionNotifier(ref.watch(subscriptionRepositoryProvider));

  // Load subscription when auth state changes
  ref.listen(authProvider, (previous, next) {
    if (next.isAuthenticated && !previous!.isAuthenticated) {
      notifier.loadSubscription();
    } else if (!next.isAuthenticated) {
      notifier.clear();
    }
  });

  // Initial load if already authenticated
  final authState = ref.read(authProvider);
  if (authState.isAuthenticated) {
    notifier.loadSubscription();
  }

  return notifier;
});

/// Is premium provider
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPremium;
});

/// Subscription tier provider
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).tier;
});
