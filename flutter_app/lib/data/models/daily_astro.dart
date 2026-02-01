import 'package:equatable/equatable.dart';

/// Daily astrology horoscope model
class DailyAstro extends Equatable {
  final String userId;
  final DateTime date;
  final String zodiacSign;
  final String content;
  final int moodScore;
  final List<int> luckyNumbers;
  final String luckyColor;
  final String? advice;
  final DateTime createdAt;

  const DailyAstro({
    required this.userId,
    required this.date,
    required this.zodiacSign,
    required this.content,
    this.moodScore = 5,
    this.luckyNumbers = const [7],
    this.luckyColor = 'mavi',
    this.advice,
    required this.createdAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  factory DailyAstro.fromJson(Map<String, dynamic> json) {
    final luckyNumbersRaw = json['lucky_numbers'];
    List<int> luckyNumbers = [7];

    if (luckyNumbersRaw != null) {
      if (luckyNumbersRaw is List) {
        luckyNumbers = luckyNumbersRaw.map((e) => e as int).toList();
      }
    }

    return DailyAstro(
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      zodiacSign: json['zodiac_sign'] as String,
      content: json['content'] as String,
      moodScore: json['mood_score'] as int? ?? 5,
      luckyNumbers: luckyNumbers,
      luckyColor: json['lucky_color'] as String? ?? 'mavi',
      advice: json['advice'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// From edge function response
  factory DailyAstro.fromFunctionResponse(
    String userId,
    Map<String, dynamic> json,
  ) {
    final luckyNumbersRaw = json['lucky_numbers'];
    List<int> luckyNumbers = [7];

    if (luckyNumbersRaw != null && luckyNumbersRaw is List) {
      luckyNumbers = luckyNumbersRaw.map((e) => (e as num).toInt()).toList();
    }

    return DailyAstro(
      userId: userId,
      date: DateTime.parse(json['date'] as String),
      zodiacSign: json['zodiac_sign'] as String,
      content: json['content'] as String,
      moodScore: json['mood_score'] as int? ?? 5,
      luckyNumbers: luckyNumbers,
      luckyColor: json['lucky_color'] as String? ?? 'mavi',
      advice: json['advice'] as String?,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T').first,
      'zodiac_sign': zodiacSign,
      'content': content,
      'mood_score': moodScore,
      'lucky_numbers': luckyNumbers,
      'lucky_color': luckyColor,
      'advice': advice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        date,
        zodiacSign,
        content,
        moodScore,
        luckyNumbers,
        luckyColor,
      ];
}
