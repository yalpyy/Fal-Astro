import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Time period for horoscope
enum HoroscopePeriod {
  yesterday('Dün', 'YESTERDAY'),
  today('Bugün', 'TODAY'),
  tomorrow('Yarın', 'TOMORROW'),
  weekly('Haftalık', 'weekly'),
  monthly('Aylık', 'monthly'),
  yearly('Yıllık', 'yearly');

  final String label;
  final String apiValue;
  const HoroscopePeriod(this.label, this.apiValue);
}

/// Horoscope data model
class HoroscopeData {
  final String sign;
  final String period;
  final String horoscopeText;
  final int careerScore;
  final int loveScore;
  final int moneyScore;
  final int luckyNumber;
  final String luckyColor;
  final String mood;
  final DateTime date;

  const HoroscopeData({
    required this.sign,
    required this.period,
    required this.horoscopeText,
    required this.careerScore,
    required this.loveScore,
    required this.moneyScore,
    required this.luckyNumber,
    required this.luckyColor,
    required this.mood,
    required this.date,
  });

  factory HoroscopeData.fromJson(Map<String, dynamic> json, String sign, String period) {
    final random = Random(DateTime.now().day + sign.hashCode);

    return HoroscopeData(
      sign: sign,
      period: period,
      horoscopeText: json['horoscope_data'] ?? '',
      careerScore: random.nextInt(5) + 5, // 5-10
      loveScore: random.nextInt(5) + 5,
      moneyScore: random.nextInt(5) + 5,
      luckyNumber: random.nextInt(99) + 1,
      luckyColor: _getLuckyColor(random),
      mood: _getMood(random),
      date: DateTime.now(),
    );
  }

  static String _getLuckyColor(Random random) {
    final colors = ['Kırmızı', 'Mavi', 'Yeşil', 'Mor', 'Turuncu', 'Pembe', 'Sarı', 'Turkuaz'];
    return colors[random.nextInt(colors.length)];
  }

  static String _getMood(Random random) {
    final moods = ['Pozitif', 'Enerjik', 'Sakin', 'Heyecanlı', 'Romantik', 'Kararlı'];
    return moods[random.nextInt(moods.length)];
  }
}

/// Horoscope API service
class HoroscopeService {
  static const String _baseUrl = 'https://horoscope-app-api.vercel.app/api/v1';

  /// Zodiac sign mapping (Turkish ID to English API name)
  static const Map<String, String> _signMapping = {
    'koc': 'aries',
    'boga': 'taurus',
    'ikizler': 'gemini',
    'yengec': 'cancer',
    'aslan': 'leo',
    'basak': 'virgo',
    'terazi': 'libra',
    'akrep': 'scorpio',
    'yay': 'sagittarius',
    'oglak': 'capricorn',
    'kova': 'aquarius',
    'balik': 'pisces',
  };

  /// Get daily horoscope
  Future<HoroscopeData> getDailyHoroscope(String zodiacId, HoroscopePeriod period) async {
    final sign = _signMapping[zodiacId] ?? 'aries';

    try {
      String endpoint;

      if (period == HoroscopePeriod.yesterday ||
          period == HoroscopePeriod.today ||
          period == HoroscopePeriod.tomorrow) {
        endpoint = '$_baseUrl/get-horoscope/daily?sign=$sign&day=${period.apiValue}';
      } else if (period == HoroscopePeriod.weekly) {
        endpoint = '$_baseUrl/get-horoscope/weekly?sign=$sign';
      } else if (period == HoroscopePeriod.monthly) {
        endpoint = '$_baseUrl/get-horoscope/monthly?sign=$sign';
      } else {
        // Yearly - use monthly as fallback since API might not support yearly
        endpoint = '$_baseUrl/get-horoscope/monthly?sign=$sign';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return HoroscopeData.fromJson(data['data'], zodiacId, period.label);
        }
      }

      // Fallback to local generated content
      return _generateLocalHoroscope(zodiacId, period);
    } catch (e) {
      // Fallback to local generated content on error
      return _generateLocalHoroscope(zodiacId, period);
    }
  }

  /// Generate local horoscope content (Turkish)
  HoroscopeData _generateLocalHoroscope(String zodiacId, HoroscopePeriod period) {
    final seed = zodiacId.hashCode + DateTime.now().day + period.index;
    final random = Random(seed);

    final horoscopeTexts = _getHoroscopeTexts(zodiacId, period, random);

    return HoroscopeData(
      sign: zodiacId,
      period: period.label,
      horoscopeText: horoscopeTexts,
      careerScore: random.nextInt(5) + 5,
      loveScore: random.nextInt(5) + 5,
      moneyScore: random.nextInt(5) + 5,
      luckyNumber: random.nextInt(99) + 1,
      luckyColor: HoroscopeData._getLuckyColor(random),
      mood: HoroscopeData._getMood(random),
      date: DateTime.now(),
    );
  }

  String _getHoroscopeTexts(String zodiacId, HoroscopePeriod period, Random random) {
    final zodiacNames = {
      'koc': 'Koç',
      'boga': 'Boğa',
      'ikizler': 'İkizler',
      'yengec': 'Yengeç',
      'aslan': 'Aslan',
      'basak': 'Başak',
      'terazi': 'Terazi',
      'akrep': 'Akrep',
      'yay': 'Yay',
      'oglak': 'Oğlak',
      'kova': 'Kova',
      'balik': 'Balık',
    };

    final name = zodiacNames[zodiacId] ?? 'Burç';

    final dailyTexts = [
      'Sevgili $name, bugün enerjin yüksek ve motivasyonun dorukta. Yeni başlangıçlar için mükemmel bir gün. İş hayatında aldığın kararlar seni bir adım öne taşıyacak. Aşk hayatında ise sürprizlere açık ol, beklemediğin bir anda güzel haberler alabilirsin.',
      'Sevgili $name, bir süredir aradığın desteği bugün itibarıyla bulmaya başlayacaksın. Tam da ihtiyacın olduğu anda doğru insanlar karşına çıkacak. Finansal konularda dikkatli ol, ani kararlardan kaçın.',
      'Sevgili $name, bugün içsel bir yolculuğa çıkman için ideal bir gün. Kendine zaman ayır ve duygularını dinle. İş hayatında yaratıcı fikirlerin takdir görecek. Sağlığına biraz daha özen göstermen gerekiyor.',
      'Sevgili $name, sosyal ilişkilerin ön planda olduğu bir gün seni bekliyor. Arkadaşlarınla vakit geçirmek ruhuna iyi gelecek. Kariyer hedeflerinde önemli adımlar atabilirsin. Aşkta sabırlı ol.',
      'Sevgili $name, bugün evrenin enerjisi seninle. Şansın yaver gidecek ve uzun süredir beklediğin fırsatlar kapını çalabilir. Maddi konularda olumlu gelişmeler yaşanabilir. Kendine güven!',
    ];

    final weeklyTexts = [
      'Bu hafta $name burcu için dönüşüm ve yenilenme zamanı. Hafta başında yoğun bir tempo beklerken, hafta ortasında işler yoluna girecek. Hafta sonu romantik sürprizlere açık ol. Finansal konularda dikkatli planlamalar yap.',
      'Sevgili $name, bu hafta kariyer odaklı bir dönem seni bekliyor. Projelerinde ilerleme kaydedecek ve üstlerinin dikkatini çekeceksin. Sağlık konularına özen göster, stres yönetimi önemli. Aşk hayatında güzel gelişmeler var.',
    ];

    final monthlyTexts = [
      'Bu ay $name burcu için büyük fırsatlar ayı! Özellikle ayın ilk yarısında iş hayatında önemli teklifler alabilirsin. Ayın ortasında aşk hayatın hareketlenecek. Son haftalarda maddi konularda rahatlamalar yaşanacak. Sağlığına dikkat et ve düzenli egzersiz yap.',
      'Sevgili $name, bu ay kişisel gelişimine odaklanman için mükemmel bir zaman. Yeni hobiler edinebilir, kurslar alabilirsin. İş hayatında sabırlı ol, ayın sonuna doğru beklediğin haberler gelecek. Aşkta açık iletişim şart.',
    ];

    switch (period) {
      case HoroscopePeriod.yesterday:
      case HoroscopePeriod.today:
      case HoroscopePeriod.tomorrow:
        return dailyTexts[random.nextInt(dailyTexts.length)];
      case HoroscopePeriod.weekly:
        return weeklyTexts[random.nextInt(weeklyTexts.length)];
      case HoroscopePeriod.monthly:
      case HoroscopePeriod.yearly:
        return monthlyTexts[random.nextInt(monthlyTexts.length)];
    }
  }
}
