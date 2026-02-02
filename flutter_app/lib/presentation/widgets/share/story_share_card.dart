import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Types of shareable content
enum ShareContentType {
  fortune,
  dream,
  astro,
}

/// Shareable story card widget
class StoryShareCard extends StatelessWidget {
  final String title;
  final String content;
  final ShareContentType type;
  final String? zodiacSign;
  final List<String>? highlights;

  const StoryShareCard({
    super.key,
    required this.title,
    required this.content,
    required this.type,
    this.zodiacSign,
    this.highlights,
  });

  IconData get _icon {
    switch (type) {
      case ShareContentType.fortune:
        return Icons.coffee;
      case ShareContentType.dream:
        return Icons.nights_stay;
      case ShareContentType.astro:
        return Icons.auto_awesome;
    }
  }

  List<Color> get _gradientColors {
    switch (type) {
      case ShareContentType.fortune:
        return [const Color(0xFF4A0E4E), const Color(0xFF1A0A2E)];
      case ShareContentType.dream:
        return [const Color(0xFF0D1B2A), const Color(0xFF1B263B)];
      case ShareContentType.astro:
        return [const Color(0xFF2D1B69), const Color(0xFF1A1A2E)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _StarsPainter(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),

                // App branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icon,
                      color: Colors.white.withOpacity(0.9),
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Fal & Astro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Zodiac sign if available
                if (zodiacSign != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      zodiacSign!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],

                // Main content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        content.length > 500
                            ? '${content.substring(0, 500)}...'
                            : content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Highlights
                if (highlights != null && highlights!.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: highlights!.take(3).map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          h,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 60),

                // Call to action
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Text(
                    'Sen de falına baktır!',
                    style: TextStyle(
                      color: Color(0xFF1A0A2E),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stars background painter
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw random stars
    final starPositions = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.05),
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.55),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.9, size.height * 0.85),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.7, size.height * 0.7),
    ];

    for (final pos in starPositions) {
      canvas.drawCircle(pos, 3, paint);
    }

    // Draw some larger stars
    paint.color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.5), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.4), 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Share service for generating and sharing story images
class StoryShareService {
  /// Capture widget as image bytes
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Save image to temp file and return path
  static Future<String?> saveToTempFile(Uint8List bytes, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving temp file: $e');
      return null;
    }
  }

  /// Share to Instagram Stories
  static Future<bool> shareToInstagramStories(String imagePath) async {
    try {
      // Try Instagram Stories deep link (iOS and Android)
      final instagramUri = Uri.parse(
        'instagram-stories://share?source_application=fal_astro',
      );

      if (await canLaunchUrl(instagramUri)) {
        // Share file first, then open Instagram
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Fal & Astro ile falıma baktım!',
        );
        return true;
      }

      // Fallback to regular share
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Fal & Astro ile falıma baktım! #FalAstro #KahveFalı',
      );
      return true;
    } catch (e) {
      debugPrint('Error sharing to Instagram: $e');
      return false;
    }
  }

  /// General share
  static Future<bool> shareImage(String imagePath, {String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: text ?? 'Fal & Astro ile falıma baktım!',
      );
      return true;
    } catch (e) {
      debugPrint('Error sharing: $e');
      return false;
    }
  }
}

/// Share button widget with preview
class ShareToStoriesButton extends StatefulWidget {
  final String title;
  final String content;
  final ShareContentType type;
  final String? zodiacSign;
  final List<String>? highlights;

  const ShareToStoriesButton({
    super.key,
    required this.title,
    required this.content,
    required this.type,
    this.zodiacSign,
    this.highlights,
  });

  @override
  State<ShareToStoriesButton> createState() => _ShareToStoriesButtonState();
}

class _ShareToStoriesButtonState extends State<ShareToStoriesButton> {
  bool _isSharing = false;

  Future<void> _shareToStories() async {
    setState(() => _isSharing = true);

    try {
      // Show preview and capture
      final bytes = await _captureStoryCard();
      if (bytes == null) {
        throw Exception('Görsel oluşturulamadı');
      }

      final path = await StoryShareService.saveToTempFile(
        bytes,
        'fal_astro_story_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (path == null) {
        throw Exception('Dosya kaydedilemedi');
      }

      await StoryShareService.shareToInstagramStories(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşım hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<Uint8List?> _captureStoryCard() async {
    final key = GlobalKey();

    // Create an offscreen widget
    final storyCard = RepaintBoundary(
      key: key,
      child: Material(
        child: StoryShareCard(
          title: this.widget.title,
          content: this.widget.content,
          type: this.widget.type,
          zodiacSign: this.widget.zodiacSign,
          highlights: this.widget.highlights,
        ),
      ),
    );

    // Use overlay to render
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -10000,
        child: SizedBox(
          width: 1080,
          height: 1920,
          child: storyCard,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Wait for render
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await StoryShareService.captureWidget(key);

    overlayEntry.remove();

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSharing ? null : _shareToStories,
      icon: _isSharing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.share),
      label: Text(_isSharing ? 'Paylaşılıyor...' : 'Hikayede Paylaş'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE1306C), // Instagram pink
        foregroundColor: Colors.white,
      ),
    );
  }
}
