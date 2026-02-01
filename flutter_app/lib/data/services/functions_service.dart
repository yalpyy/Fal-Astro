import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/fortune_reading.dart';
import '../models/symbol.dart';

/// Supabase Edge Functions service
class FunctionsService {
  final SupabaseClient _client;

  FunctionsService(this._client);

  /// Call fortune_read edge function
  Future<FortuneReadResult> readFortune({
    required FortuneIntent intent,
    required String cupImageSignedUrl,
    String? saucerImageSignedUrl,
    String locale = 'tr',
    String? customNote,
  }) async {
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.fortuneReadFunction,
        body: {
          'intent': intent.name,
          'cup_image_signed_url': cupImageSignedUrl,
          if (saucerImageSignedUrl != null)
            'saucer_image_signed_url': saucerImageSignedUrl,
          'locale': locale,
          if (customNote != null) 'custom_note': customNote,
        },
      );

      if (response.status != 200) {
        final error = response.data as Map<String, dynamic>?;
        if (error?['error'] == 'rate_limit_exceeded') {
          throw RateLimitException(
            currentUsage: error?['current_usage'] as int? ?? 0,
            limit: error?['limit'] as int? ?? 1,
            tier: error?['tier'] as String? ?? 'free',
          );
        }
        throw ServerException(
          error?['message'] as String? ?? 'Fortune read failed',
          error?['error'] as String?,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return FortuneReadResult.fromJson(data);
    } on FunctionException catch (e) {
      throw ServerException('Fortune function error: ${e.details}');
    }
  }

  /// Call daily_astro edge function
  Future<DailyAstroResult> getDailyAstro({
    String locale = 'tr',
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.dailyAstroFunction,
        body: {
          'locale': locale,
          'force_refresh': forceRefresh,
        },
      );

      if (response.status != 200) {
        final error = response.data as Map<String, dynamic>?;
        throw ServerException(
          error?['message'] as String? ?? 'Daily astro failed',
          error?['error'] as String?,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return DailyAstroResult.fromJson(data);
    } on FunctionException catch (e) {
      throw ServerException('Daily astro function error: ${e.details}');
    }
  }

  /// Call astro_report edge function
  Future<AstroReportResult> getAstroReport({
    required String reportType,
    String locale = 'tr',
  }) async {
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.astroReportFunction,
        body: {
          'report_type': reportType,
          'locale': locale,
        },
      );

      if (response.status != 200) {
        final error = response.data as Map<String, dynamic>?;
        if (error?['error'] == 'rate_limit_exceeded') {
          throw RateLimitException(
            currentUsage: error?['current_usage'] as int? ?? 0,
            limit: error?['limit'] as int? ?? 1,
            tier: error?['tier'] as String? ?? 'free',
          );
        }
        throw ServerException(
          error?['message'] as String? ?? 'Astro report failed',
          error?['error'] as String?,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return AstroReportResult.fromJson(data);
    } on FunctionException catch (e) {
      throw ServerException('Astro report function error: ${e.details}');
    }
  }

  /// Call compat_report edge function
  Future<CompatReportResult> getCompatReport({
    required DateTime partnerBirthDate,
    required String partnerBirthCity,
    required String partnerBirthCountry,
    String? partnerBirthTime,
    String? partnerName,
    String locale = 'tr',
  }) async {
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.compatReportFunction,
        body: {
          'partner_birth_date': partnerBirthDate.toIso8601String().split('T').first,
          'partner_birth_city': partnerBirthCity,
          'partner_birth_country': partnerBirthCountry,
          if (partnerBirthTime != null) 'partner_birth_time': partnerBirthTime,
          if (partnerName != null) 'partner_name': partnerName,
          'locale': locale,
        },
      );

      if (response.status != 200) {
        final error = response.data as Map<String, dynamic>?;
        throw ServerException(
          error?['message'] as String? ?? 'Compatibility report failed',
          error?['error'] as String?,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return CompatReportResult.fromJson(data);
    } on FunctionException catch (e) {
      throw ServerException('Compat report function error: ${e.details}');
    }
  }
}

/// Fortune read result from edge function
class FortuneReadResult {
  final String? readingId;
  final String resultText;
  final Timelines timelines;
  final List<Symbol> symbols;
  final String safetyNote;
  final int remainingToday;

  FortuneReadResult({
    this.readingId,
    required this.resultText,
    required this.timelines,
    required this.symbols,
    required this.safetyNote,
    required this.remainingToday,
  });

  factory FortuneReadResult.fromJson(Map<String, dynamic> json) {
    final symbolsJson = json['symbols'] as List?;
    final timelinesJson = json['timelines'] as Map<String, dynamic>?;

    return FortuneReadResult(
      readingId: json['reading_id'] as String?,
      resultText: json['result_text'] as String,
      timelines: timelinesJson != null
          ? Timelines.fromJson(timelinesJson)
          : const Timelines(near: '', mid: '', far: ''),
      symbols: symbolsJson != null
          ? symbolsJson
              .map((s) => Symbol.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
      safetyNote: json['safety_note'] as String? ?? '',
      remainingToday: json['remaining_today'] as int? ?? 0,
    );
  }
}

/// Daily astro result from edge function
class DailyAstroResult {
  final String content;
  final int moodScore;
  final List<int> luckyNumbers;
  final String luckyColor;
  final String? advice;
  final String zodiacSign;
  final String zodiacLabel;
  final String date;
  final bool cached;
  final int remainingToday;

  DailyAstroResult({
    required this.content,
    required this.moodScore,
    required this.luckyNumbers,
    required this.luckyColor,
    this.advice,
    required this.zodiacSign,
    required this.zodiacLabel,
    required this.date,
    required this.cached,
    required this.remainingToday,
  });

  factory DailyAstroResult.fromJson(Map<String, dynamic> json) {
    final luckyNumbersRaw = json['lucky_numbers'];
    List<int> luckyNumbers = [7];
    if (luckyNumbersRaw is List) {
      luckyNumbers = luckyNumbersRaw.map((e) => (e as num).toInt()).toList();
    }

    return DailyAstroResult(
      content: json['content'] as String,
      moodScore: json['mood_score'] as int? ?? 5,
      luckyNumbers: luckyNumbers,
      luckyColor: json['lucky_color'] as String? ?? 'mavi',
      advice: json['advice'] as String?,
      zodiacSign: json['zodiac_sign'] as String,
      zodiacLabel: json['zodiac_label'] as String,
      date: json['date'] as String,
      cached: json['cached'] as bool? ?? false,
      remainingToday: json['remaining_today'] as int? ?? 0,
    );
  }
}

/// Astro report result from edge function
class AstroReportResult {
  final String? reportId;
  final String reportType;
  final String zodiacSign;
  final String zodiacLabel;
  final Map<String, dynamic> chartJson;
  final String reportText;
  final Map<String, dynamic> sections;
  final String? validUntil;
  final bool cached;
  final int remainingToday;
  final String safetyNote;

  AstroReportResult({
    this.reportId,
    required this.reportType,
    required this.zodiacSign,
    required this.zodiacLabel,
    required this.chartJson,
    required this.reportText,
    required this.sections,
    this.validUntil,
    required this.cached,
    required this.remainingToday,
    required this.safetyNote,
  });

  factory AstroReportResult.fromJson(Map<String, dynamic> json) {
    return AstroReportResult(
      reportId: json['report_id'] as String?,
      reportType: json['report_type'] as String,
      zodiacSign: json['zodiac_sign'] as String,
      zodiacLabel: json['zodiac_label'] as String,
      chartJson: json['chart_json'] as Map<String, dynamic>? ?? {},
      reportText: json['report_text'] as String? ?? '',
      sections: json['sections'] as Map<String, dynamic>? ?? {},
      validUntil: json['valid_until'] as String?,
      cached: json['cached'] as bool? ?? false,
      remainingToday: json['remaining_today'] as int? ?? 0,
      safetyNote: json['safety_note'] as String? ?? '',
    );
  }
}

/// Compatibility report result from edge function
class CompatReportResult {
  final String? reportId;
  final Map<String, dynamic> user;
  final Map<String, dynamic> partner;
  final int compatibilityScore;
  final String summary;
  final List<String> strengths;
  final List<String> challenges;
  final String advice;
  final int remainingToday;
  final String safetyNote;

  CompatReportResult({
    this.reportId,
    required this.user,
    required this.partner,
    required this.compatibilityScore,
    required this.summary,
    required this.strengths,
    required this.challenges,
    required this.advice,
    required this.remainingToday,
    required this.safetyNote,
  });

  factory CompatReportResult.fromJson(Map<String, dynamic> json) {
    return CompatReportResult(
      reportId: json['report_id'] as String?,
      user: json['user'] as Map<String, dynamic>? ?? {},
      partner: json['partner'] as Map<String, dynamic>? ?? {},
      compatibilityScore: json['compatibility_score'] as int? ?? 50,
      summary: json['summary'] as String? ?? '',
      strengths: (json['strengths'] as List?)?.map((e) => e as String).toList() ?? [],
      challenges: (json['challenges'] as List?)?.map((e) => e as String).toList() ?? [],
      advice: json['advice'] as String? ?? '',
      remainingToday: json['remaining_today'] as int? ?? 0,
      safetyNote: json['safety_note'] as String? ?? '',
    );
  }
}
