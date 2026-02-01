import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../providers/auth_provider.dart';

/// Apple Sign In button
class AppleSignInButton extends ConsumerWidget {
  const AppleSignInButton({super.key});

  bool get _isApplePlatform {
    // Web'de Platform yok, önce web'i ele
    if (kIsWeb) return false;

    // iOS/macOS kontrolü (dart:io kullanmadan)
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show on Apple platforms
    if (!_isApplePlatform) {
      return const SizedBox.shrink();
    }

    return SignInWithAppleButton(
      onPressed: () => _signInWithApple(context, ref),
      style: SignInWithAppleButtonStyle.black,
      text: 'Apple ile Giriş Yap',
    );
  }

  Future<void> _signInWithApple(BuildContext context, WidgetRef ref) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final token = credential.identityToken;
      if (token != null && token.isNotEmpty) {
        await ref.read(authProvider.notifier).signInWithAppleNative(
              token,
              '', // Nonce (prod için üretilecek)
            );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apple token alınamadı.')),
          );
        }
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Apple ile giriş başarısız: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }
}
