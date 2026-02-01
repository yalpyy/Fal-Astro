import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Authentication repository
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Sign in with Apple
  Future<User> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.falastro://login-callback/',
        scopes: 'email name',
      );

      if (!response) {
        throw const AuthException('Apple sign in failed');
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 2));

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('Apple sign in failed');
      }

      return user;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Sign in with Apple (native)
  Future<User> signInWithAppleNative({
    required String idToken,
    required String nonce,
  }) async {
    try {
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: nonce,
      );

      if (response.user == null) {
        throw const AuthException('Apple sign in failed');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      // Note: This requires a server-side function or admin API
      // For now, just sign out
      await signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _client.auth.refreshSession();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-posta veya şifre hatalı';
    }
    if (message.contains('Email not confirmed')) {
      return 'E-posta adresinizi doğrulayın';
    }
    if (message.contains('User already registered')) {
      return 'Bu e-posta zaten kayıtlı';
    }
    if (message.contains('Password should be')) {
      return 'Şifre en az 6 karakter olmalı';
    }
    if (message.contains('Invalid email')) {
      return 'Geçersiz e-posta adresi';
    }
    return message;
  }
}
