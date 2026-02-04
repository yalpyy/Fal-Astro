import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/premium_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../router/route_names.dart';

/// Premium landing page with mystical video background
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initAnimations();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: PremiumDurations.slow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/login_bg.mp4',
    );

    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      _videoController.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    final authState = ref.read(authProvider);
    final profileState = ref.read(profileProvider);

    if (authState.isAuthenticated) {
      if (profileState.isOnboarded) {
        context.goNamed(RouteNames.home);
      } else {
        context.goNamed(RouteNames.onboarding);
      }
    } else {
      context.goNamed(RouteNames.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            // Premium gradient fallback
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PremiumColors.backgroundDark,
                    const Color(0xFF1A1A2E),
                    PremiumColors.primaryPurpleDark,
                  ],
                ),
              ),
            ),

          // Dark overlay with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Foreground Content with animations
          SafeArea(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Title with glow
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          PremiumColors.primaryPurple,
                          PremiumColors.accentCyan,
                          PremiumColors.primaryPurple,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Fal & Astro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Logo with glow effect
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            PremiumColors.primaryPurple.withOpacity(0.3),
                            PremiumColors.accentCyan.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: PremiumColors.primaryPurple.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumColors.primaryPurple.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: PremiumColors.accentCyan.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '✨',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Welcome Text
                    const Text(
                      'Hoşgeldiniz',
                      style: TextStyle(
                        color: PremiumColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      MysticalStrings.greeting,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Kahve falı ve kişisel astroloji deneyiminiz\nburada başlıyor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PremiumColors.textTertiary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    // Premium Start Button
                    _PremiumStartButton(
                      text: 'Hazırsak Başlayalım',
                      onPressed: _onStartPressed,
                    ),

                    const SizedBox(height: 24),

                    // KVKK Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegalLink(
                          text: 'Gizlilik Sözleşmesi',
                          onTap: () => context.pushNamed(RouteNames.privacyPolicy),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: PremiumColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _LegalLink(
                          text: 'Kullanım Koşulları',
                          onTap: () => context.pushNamed(RouteNames.termsOfService),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // KVKK Notice
                    Text(
                      'Devam ederek KVKK kapsamındaki\naydınlatma metnini kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PremiumColors.textTertiary.withOpacity(0.7),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium gradient button with glow
class _PremiumStartButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PremiumStartButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PremiumColors.primaryPurple,
            Color(0xFF9333EA),
            PremiumColors.accentCyan,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.primaryPurple.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: PremiumColors.accentCyan.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(PremiumRadius.full),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Legal link widget
class _LegalLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LegalLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: PremiumColors.textSecondary,
          fontSize: 12,
          decoration: TextDecoration.underline,
          decorationColor: PremiumColors.textTertiary,
        ),
      ),
    );
  }
}
