import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/failures.dart';
import '../models/astro_report.dart';
import '../models/daily_astro.dart';
import '../services/functions_service.dart';

/// Astrology repository
class AstroRepository {
  final SupabaseClient _client;
  final FunctionsService _functionsService;

  AstroRepository(this._client, this._functionsService);

  String? get _userId => _client.auth.currentUser?.id;

  // ============== Daily Astro ==============

  /// Get today's daily astro
  Future<DailyAstro> getDailyAstro({
    String locale = 'tr',
    bool forceRefresh = false,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final result = await _functionsService.getDailyAstro(
        locale: locale,
        forceRefresh: forceRefresh,
      );

      return DailyAstro(
        userId: _userId!,
        date: DateTime.parse(result.date),
        zodiacSign: result.zodiacSign,
        content: result.content,
        moodScore: result.moodScore,
        luckyNumbers: result.luckyNumbers,
        luckyColor: result.luckyColor,
        advice: result.advice,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get cached daily astro from database
  Future<DailyAstro?> getCachedDailyAstro() async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final today = DateTime.now().toIso8601String().split('T').first;

      final response = await _client
          .from(SupabaseConstants.dailyAstroCacheTable)
          .select()
          .eq('user_id', _userId!)
          .eq('date', today)
          .maybeSingle();

      if (response == null) return null;
      return DailyAstro.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get cached daily astro: ${e.message}');
    }
  }

  // ============== Astro Reports ==============

  /// Get all astro reports for current user
  Future<List<AstroReport>> getAstroReports({
    ReportType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      var query = _client
          .from(SupabaseConstants.astroReportsTable)
          .select()
          .eq('user_id', _userId!);

      if (type != null) {
        query = query.eq('report_type', type.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((j) => AstroReport.fromJson(j as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get astro reports: ${e.message}');
    }
  }

  /// Get a single astro report by ID
  Future<AstroReport?> getAstroReport(String id) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final response = await _client
          .from(SupabaseConstants.astroReportsTable)
          .select()
          .eq('id', id)
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return AstroReport.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get astro report: ${e.message}');
    }
  }

  /// Get latest valid report of a type
  Future<AstroReport?> getLatestValidReport(ReportType type) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from(SupabaseConstants.astroReportsTable)
          .select()
          .eq('user_id', _userId!)
          .eq('report_type', type.name)
          .eq('status', 'completed')
          .or('valid_until.is.null,valid_until.gte.$now')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return AstroReport.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to get latest report: ${e.message}');
    }
  }

  /// Generate a new astro report
  Future<AstroReport> generateAstroReport({
    required ReportType reportType,
    String locale = 'tr',
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      final result = await _functionsService.getAstroReport(
        reportType: reportType.name,
        locale: locale,
      );

      // Get from database if available
      if (result.reportId != null) {
        final report = await getAstroReport(result.reportId!);
        if (report != null) return report;
      }

      // Construct from result
      final now = DateTime.now();
      return AstroReport(
        id: result.reportId ?? '',
        userId: _userId!,
        reportType: reportType,
        chartJson: result.chartJson,
        reportText: result.reportText,
        sections: ReportSections(
          personality: result.sections['personality'] as String?,
          love: result.sections['love'] as String?,
          career: result.sections['career'] as String?,
          thisMonth: result.sections['this_month'] as String?,
          thisWeek: result.sections['this_week'] as String?,
          thisYear: result.sections['this_year'] as String?,
        ),
        status: ReportStatus.completed,
        validUntil: result.validUntil != null
            ? DateTime.parse(result.validUntil!)
            : null,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generate compatibility report
  Future<CompatReportResult> generateCompatReport({
    required DateTime partnerBirthDate,
    required String partnerBirthCity,
    required String partnerBirthCountry,
    String? partnerBirthTime,
    String? partnerName,
    String locale = 'tr',
  }) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      return await _functionsService.getCompatReport(
        partnerBirthDate: partnerBirthDate,
        partnerBirthCity: partnerBirthCity,
        partnerBirthCountry: partnerBirthCountry,
        partnerBirthTime: partnerBirthTime,
        partnerName: partnerName,
        locale: locale,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an astro report
  Future<void> deleteAstroReport(String id) async {
    if (_userId == null) throw const AuthFailure('Not authenticated');

    try {
      await _client
          .from(SupabaseConstants.astroReportsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!);
    } on PostgrestException catch (e) {
      throw ServerFailure('Failed to delete astro report: ${e.message}');
    }
  }
}
