import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/horoscope_service.dart';
import '../../../data/services/tts_service.dart';
import 'daily_horoscope_screen.dart';

/// Horoscope service provider
final horoscopeServiceProvider = Provider((ref) => HoroscopeService());

/// TTS service provider
final ttsServiceProvider = Provider((ref) => TtsService());

/// Selected period provider
final selectedPeriodProvider = StateProvider<HoroscopePeriod>((ref) => HoroscopePeriod.today);

/// Horoscope data provider
final horoscopeDataProvider = FutureProvider.family<HoroscopeData, (String, HoroscopePeriod)>(
  (ref, params) async {
    final service = ref.read(horoscopeServiceProvider);
    return service.getDailyHoroscope(params.$1, params.$2);
  },
);

/// Zodiac detail screen with new design
class ZodiacDetailScreen extends ConsumerStatefulWidget {
  final String zodiacId;

  const ZodiacDetailScreen({super.key, required this.zodiacId});

  @override
  ConsumerState<ZodiacDetailScreen> createState() => _ZodiacDetailScreenState();
}

class _ZodiacDetailScreenState extends ConsumerState<ZodiacDetailScreen> {
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;
  String _selectedZodiacId = '';

  @override
  void initState() {
    super.initState();
    _selectedZodiacId = widget.zodiacId;
    _ttsService.init();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void _toggleSpeech(String text) async {
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _ttsService.speak(text);
      // Listen for completion
      Future.delayed(Duration(seconds: _ttsService.estimateDuration(text) + 1), () {
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final horoscopeAsync = ref.watch(horoscopeDataProvider((_selectedZodiacId, selectedPeriod)));

    final zodiac = zodiacSigns.firstWhere(
      (z) => z.id == _selectedZodiacId,
      orElse: () => zodiacSigns.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and zodiac selector
            _buildHeader(context, zodiac),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Burçlar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Period tabs
            _buildPeriodTabs(selectedPeriod),

            // Content
            Expanded(
              child: horoscopeAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
                error: (e, _) => Center(
                  child: Text('Hata: $e', style: const TextStyle(color: Colors.white54)),
                ),
                data: (horoscope) => _buildContent(zodiac, horoscope),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ZodiacSign zodiac) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Zodiac selector dropdown
          GestureDetector(
            onTap: () => _showZodiacPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    zodiac.symbol,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    zodiac.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZodiacPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Burç Seçin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: zodiacSigns.length,
                  itemBuilder: (context, index) {
                    final sign = zodiacSigns[index];
                    final isSelected = sign.id == _selectedZodiacId;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedZodiacId = sign.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sign.primaryColor.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? sign.primaryColor
                                : Colors.white.withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sign.symbol,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sign.name,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodTabs(HoroscopePeriod selectedPeriod) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: HoroscopePeriod.values.map((period) {
          final isSelected = period == selectedPeriod;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(selectedPeriodProvider.notifier).state = period;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ZodiacSign zodiac, HoroscopeData horoscope) {
    final estimatedDuration = _ttsService.estimateDuration(horoscope.horoscopeText);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Constellation visual
          _buildConstellationVisual(zodiac),

          const SizedBox(height: 32),

          // Scores section
          _buildScoresSection(horoscope),

          const SizedBox(height: 24),

          // Listen button
          _buildListenButton(horoscope.horoscopeText, estimatedDuration),

          const SizedBox(height: 20),

          // Horoscope text
          _buildHoroscopeText(horoscope.horoscopeText),

          const SizedBox(height: 20),

          // Read more button
          _buildReadMoreButton(),

          const SizedBox(height: 16),

          // Ad label
          Text(
            'Reklam',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConstellationVisual(ZodiacSign zodiac) {
    return Hero(
      tag: 'zodiac_${zodiac.id}',
      child: Column(
        children: [
          // Constellation dots (simplified visual)
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(200, 120),
              painter: _ConstellationPainter(zodiac.id),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            zodiac.name,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresSection(HoroscopeData horoscope) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skorlar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Career score
          _buildScoreRow(
            icon: Icons.work_outline,
            iconColor: const Color(0xFF4A9DFF),
            label: 'Kariyer',
            score: horoscope.careerScore,
            barColor: const Color(0xFF4A9DFF),
          ),

          const SizedBox(height: 16),

          // Love score
          _buildScoreRow(
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFFFF6B6B),
            label: 'Aşk',
            score: horoscope.loveScore,
            barColor: const Color(0xFFFF6B6B),
          ),

          const SizedBox(height: 16),

          // Money score
          _buildScoreRow(
            icon: Icons.attach_money,
            iconColor: const Color(0xFF4ADE80),
            label: 'Para',
            score: horoscope.moneyScore,
            barColor: const Color(0xFF4ADE80),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int score,
    required Color barColor,
  }) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),

        // Label
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),

        // Score number
        SizedBox(
          width: 24,
          child: Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenButton(String text, int duration) {
    return GestureDetector(
      onTap: () => _toggleSpeech(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSpeaking
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSpeaking ? Icons.stop : Icons.play_arrow,
                color: _isSpeaking ? Colors.red : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSpeaking ? 'Durdur' : 'Dinle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '~$duration saniye',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoroscopeText(String text) {
    // Show truncated text with fade
    final displayText = text.length > 150 ? '${text.substring(0, 150)}...' : text;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildReadMoreButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show full reading in a dialog or navigate to full page
            _showFullReading();
          },
          borderRadius: BorderRadius.circular(16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Derinlemesine Oku',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullReading() {
    final selectedPeriod = ref.read(selectedPeriodProvider);
    final horoscopeAsync = ref.read(horoscopeDataProvider((_selectedZodiacId, selectedPeriod)));

    horoscopeAsync.whenData((horoscope) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF0D0D1A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 8),
                        const Text(
                          'Detaylı Yorum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lucky items
                            Row(
                              children: [
                                _buildLuckyItem(
                                  icon: Icons.tag,
                                  label: 'Şanslı Sayı',
                                  value: '${horoscope.luckyNumber}',
                                ),
                                const SizedBox(width: 12),
                                _buildLuckyItem(
                                  icon: Icons.palette,
                                  label: 'Şanslı Renk',
                                  value: horoscope.luckyColor,
                                ),
                                const SizedBox(width: 12),
                                _buildLuckyItem(
                                  icon: Icons.mood,
                                  label: 'Ruh Hali',
                                  value: horoscope.mood,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              horoscope.horoscopeText,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                                height: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildLuckyItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7C3AED), size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for constellation visualization
class _ConstellationPainter extends CustomPainter {
  final String zodiacId;

  _ConstellationPainter(this.zodiacId);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Generate constellation points based on zodiac
    final points = _getConstellationPoints(zodiacId, size);

    // Draw lines between points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Draw points
    for (final point in points) {
      // Outer glow
      canvas.drawCircle(
        point,
        6,
        Paint()..color = Colors.white.withValues(alpha: 0.1),
      );
      // Inner dot
      canvas.drawCircle(point, 3, paint);
    }
  }

  List<Offset> _getConstellationPoints(String zodiacId, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Different constellation patterns for each sign
    switch (zodiacId) {
      case 'kova': // Aquarius
        return [
          Offset(centerX - 60, centerY - 30),
          Offset(centerX - 30, centerY - 20),
          Offset(centerX, centerY - 10),
          Offset(centerX + 30, centerY),
          Offset(centerX + 60, centerY + 10),
          Offset(centerX + 40, centerY + 30),
          Offset(centerX + 20, centerY + 40),
        ];
      case 'balik': // Pisces
        return [
          Offset(centerX - 50, centerY - 20),
          Offset(centerX - 20, centerY - 30),
          Offset(centerX + 10, centerY - 20),
          Offset(centerX + 40, centerY),
          Offset(centerX + 10, centerY + 20),
          Offset(centerX - 20, centerY + 30),
          Offset(centerX - 50, centerY + 20),
        ];
      default: // Generic pattern
        return [
          Offset(centerX - 40, centerY - 30),
          Offset(centerX - 10, centerY - 40),
          Offset(centerX + 20, centerY - 30),
          Offset(centerX + 50, centerY - 10),
          Offset(centerX + 30, centerY + 20),
          Offset(centerX, centerY + 30),
          Offset(centerX - 30, centerY + 20),
        ];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
