import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daily_horoscope_screen.dart';

/// Daily horoscope data model
class DailyHoroscope {
  final String loveReading;
  final String careerReading;
  final String healthReading;
  final int luckyNumber;
  final String luckyColor;
  final String luckyColorHex;
  final int overallScore;
  final int loveScore;
  final int careerScore;
  final int healthScore;
  final String mood;

  const DailyHoroscope({
    required this.loveReading,
    required this.careerReading,
    required this.healthReading,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyColorHex,
    required this.overallScore,
    required this.loveScore,
    required this.careerScore,
    required this.healthScore,
    required this.mood,
  });
}

/// Generate daily horoscope based on zodiac and date
DailyHoroscope generateDailyHoroscope(String zodiacId, DateTime date) {
  // Use seeded random for consistent daily results
  final seed = zodiacId.hashCode + date.year * 10000 + date.month * 100 + date.day;
  final random = Random(seed);

  final loveReadings = [
    'Bugün aşk hayatınızda yeni kapılar açılabilir. Kalbinizi dinleyin ve içgüdülerinize güvenin.',
    'Romantik ilişkinizde daha açık iletişim kurmanın zamanı geldi. Duygularınızı paylaşmaktan çekinmeyin.',
    'Venüs etkisiyle çekiciliğiniz artıyor. Yeni tanışmalar için harika bir gün.',
    'Partnerinizle özel bir anı paylaşabilirsiniz. Birlikte geçireceğiniz zaman değerli olacak.',
    'Geçmiş ilişkilerden gelen dersler bugün size yol gösterecek. Öğrendiklerinizi uygulayın.',
    'Duygusal derinlik arayışınız sizi doğru kişiye yönlendirebilir. Sabırlı olun.',
  ];

  final careerReadings = [
    'İş hayatında önemli fırsatlar kapınızı çalabilir. Hazırlıklı olun ve proaktif davranın.',
    'Yaratıcı projeleriniz için mükemmel bir gün. Fikirlerinizi cesurca paylaşın.',
    'Ekip çalışması bugün size başarı getirecek. İş arkadaşlarınızla uyum içinde çalışın.',
    'Finansal konularda dikkatli kararlar alın. Uzun vadeli düşünmek faydalı olacak.',
    'Kariyer hedeflerinizi gözden geçirmek için ideal bir zaman. Yeni stratejiler geliştirin.',
    'Liderlik yetenekleriniz ön plana çıkıyor. İnisiyatif almaktan çekinmeyin.',
  ];

  final healthReadings = [
    'Fiziksel aktiviteye zaman ayırın. Kısa bir yürüyüş bile enerjinizi yükseltecektir.',
    'Stres yönetimi bugün önemli. Meditasyon veya nefes egzersizleri deneyin.',
    'Beslenmenize dikkat edin. Taze meyve ve sebzeler vücudunuza iyi gelecek.',
    'Uyku düzeninizi gözden geçirin. Kaliteli bir gece uykusu her şeyi değiştirebilir.',
    'Zihinsel sağlığınıza önem verin. Sevdiklerinizle vakit geçirmek iyi hissettirecek.',
    'Enerji seviyeniz yüksek. Bu enerjiyi spor veya hobilerle değerlendirin.',
  ];

  final moods = ['Pozitif', 'Enerjik', 'Sakin', 'Heyecanlı', 'Duygusal', 'Kararlı'];

  final colors = [
    ('Kırmızı', 'FF0000'),
    ('Mavi', '0000FF'),
    ('Yeşil', '00FF00'),
    ('Mor', '800080'),
    ('Turuncu', 'FFA500'),
    ('Pembe', 'FFC0CB'),
    ('Sarı', 'FFFF00'),
    ('Turkuaz', '40E0D0'),
    ('Altın', 'FFD700'),
    ('Gümüş', 'C0C0C0'),
  ];

  final colorChoice = colors[random.nextInt(colors.length)];

  return DailyHoroscope(
    loveReading: loveReadings[random.nextInt(loveReadings.length)],
    careerReading: careerReadings[random.nextInt(careerReadings.length)],
    healthReading: healthReadings[random.nextInt(healthReadings.length)],
    luckyNumber: random.nextInt(99) + 1,
    luckyColor: colorChoice.$1,
    luckyColorHex: colorChoice.$2,
    overallScore: 60 + random.nextInt(40),
    loveScore: 50 + random.nextInt(50),
    careerScore: 50 + random.nextInt(50),
    healthScore: 50 + random.nextInt(50),
    mood: moods[random.nextInt(moods.length)],
  );
}

/// Zodiac detail screen with daily readings
class ZodiacDetailScreen extends ConsumerWidget {
  final String zodiacId;

  const ZodiacDetailScreen({super.key, required this.zodiacId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zodiac = zodiacSigns.firstWhere(
      (z) => z.id == zodiacId,
      orElse: () => zodiacSigns.first,
    );

    final horoscope = generateDailyHoroscope(zodiacId, DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'zodiac_$zodiacId',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        zodiac.primaryColor,
                        zodiac.secondaryColor,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative elements
                      Positioned(
                        top: -80,
                        right: -80,
                        child: _GlassCircle(size: 200, opacity: 0.1),
                      ),
                      Positioned(
                        bottom: -60,
                        left: -60,
                        child: _GlassCircle(size: 150, opacity: 0.15),
                      ),
                      // Content
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Text(
                                zodiac.symbol,
                                style: const TextStyle(
                                  fontSize: 64,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                zodiac.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                zodiac.dateRange,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall score card
                  _ScoreCard(
                    title: 'Günlük Genel Puan',
                    score: horoscope.overallScore,
                    color: zodiac.primaryColor,
                    mood: horoscope.mood,
                  ),
                  const SizedBox(height: 16),

                  // Meta data cards
                  Row(
                    children: [
                      Expanded(
                        child: _MetaCard(
                          icon: Icons.tag,
                          title: 'Günün Sayısı',
                          value: '${horoscope.luckyNumber}',
                          color: zodiac.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetaCard(
                          icon: Icons.palette,
                          title: 'Şanslı Renk',
                          value: horoscope.luckyColor,
                          color: Color(int.parse('FF${horoscope.luckyColorHex}', radix: 16)),
                          showColorDot: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reading sections
                  _ReadingCard(
                    icon: Icons.favorite,
                    title: 'Aşk',
                    reading: horoscope.loveReading,
                    score: horoscope.loveScore,
                    color: const Color(0xFFE91E63),
                    gradientColors: [
                      const Color(0xFFE91E63).withOpacity(0.1),
                      const Color(0xFFF48FB1).withOpacity(0.05),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _ReadingCard(
                    icon: Icons.work,
                    title: 'İş',
                    reading: horoscope.careerReading,
                    score: horoscope.careerScore,
                    color: const Color(0xFF2196F3),
                    gradientColors: [
                      const Color(0xFF2196F3).withOpacity(0.1),
                      const Color(0xFF90CAF9).withOpacity(0.05),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _ReadingCard(
                    icon: Icons.health_and_safety,
                    title: 'Sağlık',
                    reading: horoscope.healthReading,
                    score: horoscope.healthScore,
                    color: const Color(0xFF4CAF50),
                    gradientColors: [
                      const Color(0xFF4CAF50).withOpacity(0.1),
                      const Color(0xFFA5D6A7).withOpacity(0.05),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass circle decoration
class _GlassCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlassCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
        border: Border.all(
          color: Colors.white.withOpacity(opacity * 2),
          width: 1,
        ),
      ),
    );
  }
}

/// Overall score card with liquid glass effect
class _ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final Color color;
  final String mood;

  const _ScoreCard({
    required this.title,
    required this.score,
    required this.color,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.mood, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Ruh Hali: $mood',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Meta data card (lucky number, color)
class _MetaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool showColorDot;

  const _MetaCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.showColorDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showColorDot) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reading card with gradient and liquid glass effect
class _ReadingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reading;
  final int score;
  final Color color;
  final List<Color> gradientColors;

  const _ReadingCard({
    required this.icon,
    required this.title,
    required this.reading,
    required this.score,
    required this.color,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Reading text
          Text(
            reading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
