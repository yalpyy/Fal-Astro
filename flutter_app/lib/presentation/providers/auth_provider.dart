import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../env/env.dart';

/// Auth state enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  unconfigured,
}

/// Auth state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnconfigured => status == AuthStatus.unconfigured;
}

/// Supabase client provider - returns null if not configured
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!Env.isConfigured) {
    throw StateError('Supabase is not configured');
  }
  return Supabase.instance.client;
});

/// Safe supabase client provider - returns null if not configured
final safeSupabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!Env.isConfigured) {
    return null;
  }
  try {
    // Check if Supabase was initialized
    final instance = Supabase.instance;
    return instance.client;
  } catch (e) {
    // Supabase.initialize() was not called
    debugPrint('Supabase not initialized: $e');
    return null;
  }
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  if (client == null) return null;
  return AuthRepository(client);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository? _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // If auth repository is null, we're in unconfigured/demo mode
    if (_authRepository == null) {
      state = const AuthState(status: AuthStatus.unconfigured);
      return;
    }

    // Check current user
    final user = _authRepository.currentUser;
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen to auth changes
    _authRepository.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: authState.session?.user,
        );
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (_authRepository == null) {
      state = state.copyWith(error: 'Supabase is not configured');
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    if (_authRepository == null) {
      state = state.copyWith(error: 'Supabase is not configured');
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithApple() async {
    if (_authRepository == null) {
      state = state.copyWith(error: 'Supabase is not configured');
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _authRepository.signInWithApple();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithAppleNative(String idToken, String nonce) async {
    if (_authRepository == null) {
      state = state.copyWith(error: 'Supabase is not configured');
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _authRepository.signInWithAppleNative(
        idToken: idToken,
        nonce: nonce,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_authRepository == null) {
      state = state.copyWith(error: 'Supabase is not configured');
      return;
    }

    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signOut() async {
    if (_authRepository == null) return;
    await _authRepository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> deleteAccount() async {
    if (_authRepository == null) return;
    await _authRepository.deleteAccount();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
