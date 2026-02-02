import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Mystical loading overlay with atmospheric animations
/// Creates anticipation and premium feel for fortune readings
class MysticLoadingOverlay extends StatefulWidget {
  final Future<void> Function() onLoad;
  final VoidCallback onComplete;
  final String? title;
  final List<String>? loadingMessages;
  final Duration minimumDuration;
  final MysticLoadingType type;

  const MysticLoadingOverlay({
    super.key,
    required this.onLoad,
    required this.onComplete,
    this.title,
    this.loadingMessages,
    this.minimumDuration = const Duration(seconds: 4),
    this.type = MysticLoadingType.fortune,
  });

  @override
  State<MysticLoadingOverlay> createState() => _MysticLoadingOverlayState();
}

class _MysticLoadingOverlayState extends State<MysticLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  bool _loadComplete = false;
  bool _minimumTimePassed = false;

  List<String> get _messages {
    if (widget.loadingMessages != null && widget.loadingMessages!.isNotEmpty) {
      return widget.loadingMessages!;
    }
    return _getDefaultMessages();
  }

  List<String> _getDefaultMessages() {
    switch (widget.type) {
      case MysticLoadingType.fortune:
        return [
          'Fincanınız okunuyor...',
          'Semboller analiz ediliyor...',
          'Geleceğe bakılıyor...',
          'Mesajlar yorumlanıyor...',
          'Falınız hazırlanıyor...',
        ];
      case MysticLoadingType.dream:
        return [
          'Rüyanız analiz ediliyor...',
          'Semboller çözümleniyor...',
          'Bilinçaltı yorumlanıyor...',
          'Mesajlar ortaya çıkıyor...',
          'Yorumunuz hazırlanıyor...',
        ];
      case MysticLoadingType.astro:
        return [
          'Yıldızlar hizalanıyor...',
          'Gezegenler inceleniyor...',
          'Burç haritanız çiziliyor...',
          'Kozmik enerjiler okunuyor...',
          'Raporunuz hazırlanıyor...',
        ];
      case MysticLoadingType.compatibility:
        return [
          'Burç uyumunuz hesaplanıyor...',
          'Gezegen konumları karşılaştırılıyor...',
          'Elementel uyum analiz ediliyor...',
          'Kozmik bağlar inceleniyor...',
          'Uyum raporunuz hazırlanıyor...',
        ];
    }
  }

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    _startMessageRotation();
    _startLoading();
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
        });
      }
    });
  }

  Future<void> _startLoading() async {
    // Start minimum timer
    Future.delayed(widget.minimumDuration, () {
      _minimumTimePassed = true;
      _checkComplete();
    });

    // Execute actual loading
    try {
      await widget.onLoad();
    } catch (e) {
      // Handle error silently, let caller handle it
    }

    _loadComplete = true;
    _checkComplete();
  }

  void _checkComplete() {
    if (_loadComplete && _minimumTimePassed && mounted) {
      _fadeController.reverse().then((_) {
        widget.onComplete();
      });
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated mystical symbol
              AnimatedBuilder(
                animation: Listenable.merge([_rotationController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationController.value * 2 * pi,
                      child: _buildMysticSymbol(colorScheme),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Title
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Animated loading message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _messages[_currentMessageIndex],
                  key: ValueKey(_currentMessageIndex),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Progress dots
              _buildProgressDots(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMysticSymbol(ColorScheme colorScheme) {
    IconData icon;
    switch (widget.type) {
      case MysticLoadingType.fortune:
        icon = Icons.coffee;
        break;
      case MysticLoadingType.dream:
        icon = Icons.nights_stay;
        break;
      case MysticLoadingType.astro:
        icon = Icons.auto_awesome;
        break;
      case MysticLoadingType.compatibility:
        icon = Icons.favorite;
        break;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 48,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildProgressDots(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.3;
            final progress = (_pulseController.value + delay) % 1.0;
            final opacity = 0.3 + (0.7 * sin(progress * pi));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(opacity),
              ),
            );
          },
        );
      }),
    );
  }
}

enum MysticLoadingType {
  fortune,
  dream,
  astro,
  compatibility,
}

/// Helper to show mystic loading as a full-screen overlay
Future<T?> showMysticLoading<T>({
  required BuildContext context,
  required Future<T> Function() load,
  String? title,
  List<String>? messages,
  Duration minimumDuration = const Duration(seconds: 4),
  MysticLoadingType type = MysticLoadingType.fortune,
}) async {
  T? result;

  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => MysticLoadingOverlay(
      title: title,
      loadingMessages: messages,
      minimumDuration: minimumDuration,
      type: type,
      onLoad: () async {
        result = await load();
      },
      onComplete: () {
        Navigator.of(context).pop();
      },
    ),
  );

  return result;
}

/// Reveal animation for showing results
class MysticRevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const MysticRevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<MysticRevealAnimation> createState() => _MysticRevealAnimationState();
}

class _MysticRevealAnimationState extends State<MysticRevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
