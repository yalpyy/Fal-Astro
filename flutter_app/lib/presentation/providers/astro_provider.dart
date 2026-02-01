import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/astro_report.dart';
import '../../data/models/daily_astro.dart';
import '../../data/repositories/astro_repository.dart';
import '../../data/services/functions_service.dart';
import 'fortune_provider.dart';
import 'auth_provider.dart';

/// Astro repository provider
final astroRepositoryProvider = Provider<AstroRepository>((ref) {
  return AstroRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(functionsServiceProvider),
  );
});

/// Daily astro state
class DailyAstroState {
  final DailyAstro? astro;
  final bool isLoading;
  final String? error;

  const DailyAstroState({
    this.astro,
    this.isLoading = false,
    this.error,
  });

  DailyAstroState copyWith({
    DailyAstro? astro,
    bool? isLoading,
    String? error,
  }) {
    return DailyAstroState(
      astro: astro ?? this.astro,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Daily astro notifier
class DailyAstroNotifier extends StateNotifier<DailyAstroState> {
  final AstroRepository _repository;

  DailyAstroNotifier(this._repository) : super(const DailyAstroState());

  Future<void> loadDailyAstro({
    String locale = 'tr',
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final astro = await _repository.getDailyAstro(
        locale: locale,
        forceRefresh: forceRefresh,
      );
      state = DailyAstroState(astro: astro);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const DailyAstroState();
  }
}

/// Daily astro provider
final dailyAstroProvider =
    StateNotifierProvider<DailyAstroNotifier, DailyAstroState>((ref) {
  return DailyAstroNotifier(ref.watch(astroRepositoryProvider));
});

/// Astro reports list state
class AstroReportsState {
  final List<AstroReport> reports;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const AstroReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  AstroReportsState copyWith({
    List<AstroReport>? reports,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return AstroReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Astro reports list notifier
class AstroReportsNotifier extends StateNotifier<AstroReportsState> {
  final AstroRepository _repository;
  static const int _pageSize = 20;

  AstroReportsNotifier(this._repository) : super(const AstroReportsState());

  Future<void> loadReports({
    ReportType? type,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final offset = refresh ? 0 : state.reports.length;
      final reports = await _repository.getAstroReports(
        type: type,
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = AstroReportsState(
          reports: reports,
          hasMore: reports.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          reports: [...state.reports, ...reports],
          hasMore: reports.length >= _pageSize,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addReport(AstroReport report) {
    state = state.copyWith(reports: [report, ...state.reports]);
  }

  void removeReport(String id) {
    state = state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
    );
  }

  void clear() {
    state = const AstroReportsState();
  }
}

/// Astro reports list provider
final astroReportsProvider =
    StateNotifierProvider<AstroReportsNotifier, AstroReportsState>((ref) {
  return AstroReportsNotifier(ref.watch(astroRepositoryProvider));
});

/// Generate report state
class GenerateReportState {
  final bool isLoading;
  final AstroReport? result;
  final String? error;

  const GenerateReportState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  GenerateReportState copyWith({
    bool? isLoading,
    AstroReport? result,
    String? error,
  }) {
    return GenerateReportState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// Generate report notifier
class GenerateReportNotifier extends StateNotifier<GenerateReportState> {
  final AstroRepository _repository;
  final AstroReportsNotifier _reportsNotifier;

  GenerateReportNotifier(this._repository, this._reportsNotifier)
      : super(const GenerateReportState());

  Future<void> generateReport({
    required ReportType reportType,
    String locale = 'tr',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _repository.generateAstroReport(
        reportType: reportType,
        locale: locale,
      );

      _reportsNotifier.addReport(report);
      state = GenerateReportState(result: report);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const GenerateReportState();
  }
}

/// Generate report provider
final generateReportProvider =
    StateNotifierProvider<GenerateReportNotifier, GenerateReportState>((ref) {
  return GenerateReportNotifier(
    ref.watch(astroRepositoryProvider),
    ref.watch(astroReportsProvider.notifier),
  );
});

/// Single astro report provider
final astroReportProvider =
    FutureProvider.family<AstroReport?, String>((ref, id) async {
  final repository = ref.watch(astroRepositoryProvider);
  return repository.getAstroReport(id);
});

/// Latest natal report provider
final latestNatalReportProvider = FutureProvider<AstroReport?>((ref) async {
  final repository = ref.watch(astroRepositoryProvider);
  return repository.getLatestValidReport(ReportType.natal);
});
