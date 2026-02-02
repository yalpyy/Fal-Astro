import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart'; // 1. EKLENDİ
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import 'widgets/apple_sign_in_button.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/email_sign_in_form.dart';

/// Authentication screen
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _showEmailForm = false;
  late VideoPlayerController _videoController; // 2. Video Controller Tanımlandı

  @override
  void initState() {
    super.initState();
    // 3. Video Başlatma Ayarları
    _videoController = VideoPlayerController.asset("assets/videos/login_bg.mp4")
      ..initialize().then((_) {
        // Video yüklendiğinde:
        _videoController.setLooping(true); // Sürekli döngü
        _videoController.setVolume(0.0);   // Sessiz
        _videoController.play();           // Oynat
        setState(() {}); // Ekranı güncelle ki video görünsün
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // 4. Hafıza Sızıntısını Önle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // Arkaplan koyu olacağı için colorScheme'i birazdan manuel override edeceğiz veya
    // yazı renklerini beyaza çekeceğiz.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Klavye açılınca video sıkışmasın diye resize false yapıyoruz
      resizeToAvoidBottomInset: false, 
      backgroundColor: Colors.black, // Video yüklenene kadar siyah kalsın
      
      // 5. STACK YAPISI: Katmanlar üst üste biner
      body: Stack(
        children: [
          // KATMAN 1 (EN ARKA): Video Player
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // Ekranı kapla (crop yaparak)
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(color: Colors.black), // Yüklenirken siyah ekran

          // KATMAN 2 (ORTA): Siyah Perde (Overlay)
          // Yazılar video üstünde okunsun diye %60 siyahlık
          Container(
            color: Colors.black.withOpacity(0.6), 
          ),

          // KATMAN 3 (EN ÖN): Senin Orijinal İçeriğin
          // Positioned.fill kullanarak tüm ekranı kaplamasını sağlıyoruz
          Positioned.fill(
            child: LoadingOverlay(
              isLoading: authState.isLoading,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      Icon(
                        Icons.auto_awesome,
                        size: 80,
                        // Arkaplan koyu olduğu için rengi parlatıyoruz
                        color: Colors.white, 
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Fal & Astro',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              // Koyu zemin üzerine beyaz yazı
                              color: Colors.white, 
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Kişisel kahve falı ve astroloji yorumları',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              // Hafif gri-beyaz
                              color: Colors.white70, 
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Error message
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // Hata kutusunu biraz şeffaf yapalım
                            color: colorScheme.errorContainer.withOpacity(0.9), 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    ref.read(authProvider.notifier).clearError(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Apple Sign In (iOS only)
                      const AppleSignInButton(),
                      const SizedBox(height: 12),

                      // Google Sign In
                      const GoogleSignInButton(),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'veya',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email toggle
                      if (!_showEmailForm)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _showEmailForm = true),
                          icon: const Icon(Icons.email_outlined, color: Colors.white),
                          label: const Text(
                            'E-posta ile devam et',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white54),
                          ),
                        )
                      else
                        // Form widget'ını Container içine alıp okunurluğu artırabiliriz
                        // veya direkt koyabiliriz. Şimdilik direkt koyuyorum.
                        // NOT: EmailSignInForm içindeki yazı renklerinin de
                        // koyu temaya uyumlu (beyaz) olması gerekebilir.
                        const EmailSignInForm(),

                      const SizedBox(height: 32),

                      // Disclaimer
                      Text(
                        'Devam ederek Gizlilik Politikası ve Kullanım Koşullarını kabul etmiş olursunuz.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white38,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
