import 'dart:math';
import 'astrology_calculator.dart';

/// Daily horoscope generator using planetary positions
/// No external API required - generates horoscopes based on astronomical data
class DailyHoroscopeGenerator {
  static final _random = Random();

  /// Generate daily horoscope for a zodiac sign
  static DailyHoroscope generate(String sign, {DateTime? date}) {
    date ??= DateTime.now();

    // Get current planetary positions
    final positions = AstrologyCalculator.getCurrentPositions();

    // Calculate aspects affecting this sign
    final signIndex = AstrologyCalculator.zodiacSigns.indexOf(sign.toLowerCase());
    if (signIndex == -1) {
      throw ArgumentError('Invalid zodiac sign: $sign');
    }

    // Determine daily energy based on moon and planetary positions
    final moonAspect = _calculateAspect(signIndex,
        AstrologyCalculator.zodiacSigns.indexOf(positions.moon.sign));
    final sunAspect = _calculateAspect(signIndex,
        AstrologyCalculator.zodiacSigns.indexOf(positions.sun.sign));

    // Generate scores based on aspects
    final loveScore = _calculateScore(moonAspect, positions.venus.sign, sign);
    final careerScore = _calculateScore(sunAspect, positions.mars.sign, sign);
    final healthScore = _calculateScore(moonAspect, positions.saturn.sign, sign);
    final overallScore = ((loveScore + careerScore + healthScore) / 3).round();

    // Get lucky numbers based on date and sign
    final luckyNumbers = _generateLuckyNumbers(date, signIndex);

    // Get lucky color
    final luckyColor = _getLuckyColor(signIndex, date.weekday);

    // Generate horoscope text
    final generalText = _generateGeneralText(sign, positions, moonAspect, sunAspect);
    final loveText = _generateLoveText(sign, positions, loveScore);
    final careerText = _generateCareerText(sign, positions, careerScore);
    final healthText = _generateHealthText(sign, positions, healthScore);

    return DailyHoroscope(
      sign: sign,
      date: date,
      generalText: generalText,
      loveText: loveText,
      careerText: careerText,
      healthText: healthText,
      overallScore: overallScore,
      loveScore: loveScore,
      careerScore: careerScore,
      healthScore: healthScore,
      luckyNumbers: luckyNumbers,
      luckyColor: luckyColor,
      moonPhase: positions.moonPhase,
      planetaryInfluence: _getPlanetaryInfluence(positions, sign),
    );
  }

  /// Calculate aspect between two signs (0-6)
  static int _calculateAspect(int sign1Index, int sign2Index) {
    final diff = (sign1Index - sign2Index).abs();
    return diff > 6 ? 12 - diff : diff;
  }

  /// Calculate score based on aspects
  static int _calculateScore(int aspect, String influencingSign, String targetSign) {
    // Aspect scoring
    final aspectScores = {
      0: 85, // Conjunction
      1: 60, // Semi-sextile
      2: 80, // Sextile
      3: 50, // Square
      4: 95, // Trine
      5: 55, // Quincunx
      6: 70, // Opposition
    };

    int score = aspectScores[aspect] ?? 70;

    // Element compatibility bonus
    final targetElement = _getElement(targetSign);
    final influenceElement = _getElement(influencingSign);

    if (targetElement == influenceElement) {
      score += 10;
    } else if (_areCompatibleElements(targetElement, influenceElement)) {
      score += 5;
    }

    // Add some daily variation
    score += _random.nextInt(10) - 5;

    return score.clamp(40, 100);
  }

  static String _getElement(String sign) {
    final elements = {
      'aries': 'fire', 'leo': 'fire', 'sagittarius': 'fire',
      'taurus': 'earth', 'virgo': 'earth', 'capricorn': 'earth',
      'gemini': 'air', 'libra': 'air', 'aquarius': 'air',
      'cancer': 'water', 'scorpio': 'water', 'pisces': 'water',
    };
    return elements[sign.toLowerCase()] ?? 'fire';
  }

  static bool _areCompatibleElements(String e1, String e2) {
    return (e1 == 'fire' && e2 == 'air') ||
           (e1 == 'air' && e2 == 'fire') ||
           (e1 == 'earth' && e2 == 'water') ||
           (e1 == 'water' && e2 == 'earth');
  }

  static List<int> _generateLuckyNumbers(DateTime date, int signIndex) {
    final seed = date.year * 10000 + date.month * 100 + date.day + signIndex;
    final rng = Random(seed);
    final numbers = <int>{};
    while (numbers.length < 3) {
      numbers.add(rng.nextInt(49) + 1);
    }
    return numbers.toList()..sort();
  }

  static String _getLuckyColor(int signIndex, int weekday) {
    final colors = [
      ['Kırmızı', 'Turuncu', 'Altın'],      // Koç
      ['Yeşil', 'Pembe', 'Toprak Tonları'], // Boğa
      ['Sarı', 'Açık Mavi', 'Gümüş'],       // İkizler
      ['Gümüş', 'Beyaz', 'Deniz Mavisi'],   // Yengeç
      ['Altın', 'Turuncu', 'Mor'],          // Aslan
      ['Lacivert', 'Gri', 'Bej'],           // Başak
      ['Pembe', 'Açık Mavi', 'Lavanta'],    // Terazi
      ['Bordo', 'Siyah', 'Koyu Kırmızı'],   // Akrep
      ['Mor', 'Mavi', 'Turkuaz'],           // Yay
      ['Kahverengi', 'Siyah', 'Koyu Yeşil'],// Oğlak
      ['Elektrik Mavisi', 'Gümüş', 'Mor'],  // Kova
      ['Deniz Yeşili', 'Lila', 'Aqua'],     // Balık
    ];
    return colors[signIndex][weekday % 3];
  }

  static String _getPlanetaryInfluence(PlanetaryPositions positions, String sign) {
    final influences = <String>[];

    if (positions.mercury.sign == sign) influences.add('Merkür');
    if (positions.venus.sign == sign) influences.add('Venüs');
    if (positions.mars.sign == sign) influences.add('Mars');
    if (positions.jupiter.sign == sign) influences.add('Jüpiter');
    if (positions.saturn.sign == sign) influences.add('Satürn');

    if (influences.isEmpty) {
      return 'Ay ${AstrologyCalculator.zodiacTurkish[AstrologyCalculator.zodiacSigns.indexOf(positions.moon.sign)]} burcunda';
    }
    return '${influences.join(", ")} etkisi altında';
  }

  // ============ TEXT GENERATORS ============

  static String _generateGeneralText(
    String sign,
    PlanetaryPositions positions,
    int moonAspect,
    int sunAspect
  ) {
    final signTr = AstrologyCalculator.zodiacTurkish[
        AstrologyCalculator.zodiacSigns.indexOf(sign.toLowerCase())];
    final moonSignTr = AstrologyCalculator.zodiacTurkish[
        AstrologyCalculator.zodiacSigns.indexOf(positions.moon.sign)];

    final templates = _getGeneralTemplates(moonAspect, sunAspect);
    final template = templates[_random.nextInt(templates.length)];

    return template
        .replaceAll('{sign}', signTr)
        .replaceAll('{moon_sign}', moonSignTr)
        .replaceAll('{moon_phase}', positions.moonPhase);
  }

  static List<String> _getGeneralTemplates(int moonAspect, int sunAspect) {
    if (moonAspect <= 2 && sunAspect <= 2) {
      // Harmonious day
      return [
        'Bugün {sign} burçları için enerjik bir gün! Ay {moon_sign} burcunda ve size olumlu açılar yapıyor. {moon_phase} döneminde planlarınızı hayata geçirmek için ideal bir zaman.',
        '{sign} burcu, bugün kozmik enerjiler sizinle uyum içinde. {moon_sign} burcundaki Ay, sezgilerinizi güçlendiriyor. Kendinize güvenin!',
        'Gökyüzü bugün {sign} burçlarına gülümsüyor. {moon_phase} etkisiyle yaratıcılığınız dorukta olacak.',
      ];
    } else if (moonAspect >= 4 || sunAspect >= 4) {
      // Challenging day
      return [
        '{sign} burcu, bugün biraz dikkatli olmanız gereken bir gün. Ay {moon_sign} burcunda zorlu açılar yapıyor. Sabırlı olun ve büyük kararları erteleyin.',
        'Bugün {sign} burçları için bazı engeller ortaya çıkabilir. {moon_phase} döneminde iç sesinizi dinleyin ve aceleden kaçının.',
        '{sign} burcu, kozmik enerjiler bugün sizi test edebilir. {moon_sign} Ay\'ı duygusal derinlik getiriyor, kendi ihtiyaçlarınıza odaklanın.',
      ];
    } else {
      // Neutral day
      return [
        '{sign} burcu için dengeli bir gün. Ay {moon_sign} burcunda seyrederken, günlük rutinlerinize odaklanabilirsiniz. {moon_phase} enerjisini değerlendirin.',
        'Bugün {sign} burçları için sakin ama verimli geçecek. {moon_sign} Ay\'ı pratik konulara dikkat çekiyor.',
        '{sign} burcu, bugün adım adım ilerleme günü. {moon_phase} döneminde küçük ama önemli detaylara dikkat edin.',
      ];
    }
  }

  static String _generateLoveText(String sign, PlanetaryPositions positions, int score) {
    final venusSignTr = AstrologyCalculator.zodiacTurkish[
        AstrologyCalculator.zodiacSigns.indexOf(positions.venus.sign)];

    final templates = score >= 75
        ? [
            'Venüs {venus_sign} burcunda, aşk hayatınızı olumlu etkiliyor. İlişkinizde romantik anlar yaşayabilirsiniz.',
            'Bugün duygusal bağlarınız güçleniyor. {venus_sign} Venüs\'ü çekiciliğinizi artırıyor.',
            'Aşk kapınızı çalabilir! Venüs enerjisi sizinle ve yeni tanışmalar için açık olun.',
          ]
        : score >= 50
            ? [
                'Aşk hayatında sakin bir gün. Venüs {venus_sign} burcunda, mevcut ilişkinize odaklanın.',
                'Duygusal konularda dengeli bir yaklaşım sergileyin. {venus_sign} Venüs\'ü sabır istiyor.',
                'İlişkilerde iletişim önemli. Partnerinizi dinlemeye zaman ayırın.',
              ]
            : [
                'Bugün duygusal konularda biraz mesafeli olabilirsiniz. Kendinize zaman tanıyın.',
                'Aşk hayatında beklenmedik gelişmeler olabilir. Sakin kalın ve tepkisel olmayın.',
                'Venüs {venus_sign} burcunda zorlayıcı açılar yapıyor. Sabırlı olun.',
              ];

    return templates[_random.nextInt(templates.length)]
        .replaceAll('{venus_sign}', venusSignTr);
  }

  static String _generateCareerText(String sign, PlanetaryPositions positions, int score) {
    final marsSignTr = AstrologyCalculator.zodiacTurkish[
        AstrologyCalculator.zodiacSigns.indexOf(positions.mars.sign)];

    final templates = score >= 75
        ? [
            'Mars {mars_sign} burcunda, kariyer hedefleriniz için harika bir gün! İnisiyatif alın.',
            'İş hayatında önemli fırsatlar kapınızı çalabilir. Enerjiniz yüksek, bunu değerlendirin.',
            'Profesyonel başarılar için ideal bir dönem. Projelerinizi ilerletin.',
          ]
        : score >= 50
            ? [
                'Kariyer konusunda istikrarlı bir gün. {mars_sign} Mars\'ı düzenli çalışmayı destekliyor.',
                'İş yerinde rutin akışı koruyun. Büyük değişiklikler için henüz erken.',
                'Mesleki konularda sabırlı adımlar atın. Sonuçlar zamanla gelecek.',
              ]
            : [
                'İş hayatında bazı gecikmeler yaşanabilir. Planlarınızı esnek tutun.',
                'Kariyer hedeflerinizi gözden geçirmek için iyi bir gün. Aceleci olmayın.',
                'Mars {mars_sign} burcunda zorlu geçitler yapıyor. Çatışmalardan kaçının.',
              ];

    return templates[_random.nextInt(templates.length)]
        .replaceAll('{mars_sign}', marsSignTr);
  }

  static String _generateHealthText(String sign, PlanetaryPositions positions, int score) {
    final templates = score >= 75
        ? [
            'Bugün enerjiniz yüksek! Fiziksel aktiviteler için ideal bir gün.',
            'Sağlık durumunuz oldukça iyi. Yeni bir spor veya aktivite deneyebilirsiniz.',
            'Vücudunuz size olumlu sinyaller veriyor. Bu enerjiyi değerlendirin.',
          ]
        : score >= 50
            ? [
                'Sağlık açısından dengeli bir gün. Düzenli beslenmeye dikkat edin.',
                'Orta düzey aktiviteler bugün için ideal. Aşırıya kaçmayın.',
                'Kendinize bakım zamanı ayırın. Stres yönetimi önemli.',
              ]
            : [
                'Bugün biraz yorgun hissedebilirsiniz. Dinlenmeye öncelik verin.',
                'Sağlık konusunda dikkatli olun. Bol su için ve erken yatın.',
                'Vücudunuzun sinyallerini dinleyin. Zorlayıcı aktivitelerden kaçının.',
              ];

    return templates[_random.nextInt(templates.length)];
  }
}

/// Daily horoscope data model
class DailyHoroscope {
  final String sign;
  final DateTime date;
  final String generalText;
  final String loveText;
  final String careerText;
  final String healthText;
  final int overallScore;
  final int loveScore;
  final int careerScore;
  final int healthScore;
  final List<int> luckyNumbers;
  final String luckyColor;
  final String moonPhase;
  final String planetaryInfluence;

  const DailyHoroscope({
    required this.sign,
    required this.date,
    required this.generalText,
    required this.loveText,
    required this.careerText,
    required this.healthText,
    required this.overallScore,
    required this.loveScore,
    required this.careerScore,
    required this.healthScore,
    required this.luckyNumbers,
    required this.luckyColor,
    required this.moonPhase,
    required this.planetaryInfluence,
  });

  Map<String, dynamic> toJson() => {
    'sign': sign,
    'date': date.toIso8601String().split('T')[0],
    'general': generalText,
    'love': loveText,
    'career': careerText,
    'health': healthText,
    'scores': {
      'overall': overallScore,
      'love': loveScore,
      'career': careerScore,
      'health': healthScore,
    },
    'lucky_numbers': luckyNumbers,
    'lucky_color': luckyColor,
    'moon_phase': moonPhase,
    'planetary_influence': planetaryInfluence,
  };
}
