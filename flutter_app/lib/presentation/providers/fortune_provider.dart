import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/fortune_reading.dart';
import '../../data/models/fortune_feedback.dart';
import '../../data/repositories/fortune_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/functions_service.dart';
import '../../data/services/local_cache_service.dart';
import 'auth_provider.dart';

/// Storage service provider - returns null if Supabase not configured
final storageServiceProvider = Provider<StorageService?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  if (client == null) return null;
  return StorageService(client);
});

/// Functions service provider - returns null if Supabase not configured
final functionsServiceProvider = Provider<FunctionsService?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  if (client == null) return null;
  return FunctionsService(client);
});

/// Local cache service provider
final localCacheServiceProvider = FutureProvider<LocalCacheService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocalCacheService(prefs);
});

/// Fortune repository provider - returns null if Supabase not configured
final fortuneRepositoryProvider = Provider<FortuneRepository?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  final storage = ref.watch(storageServiceProvider);
  final functions = ref.watch(functionsServiceProvider);

  if (client == null || storage == null || functions == null) return null;

  return FortuneRepository(client, storage, functions);
});

/// Fortune list state
class FortuneListState {
  final List<FortuneReading> readings;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FortuneListState({
    this.readings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FortuneListState copyWith({
    List<FortuneReading>? readings,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return FortuneListState(
      readings: readings ?? this.readings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Fortune list notifier
class FortuneListNotifier extends StateNotifier<FortuneListState> {
  final FortuneRepository? _repository;
  static const int _pageSize = 20;

  FortuneListNotifier(this._repository) : super(const FortuneListState());

  Future<void> loadReadings({bool refresh = false}) async {
    if (_repository == null) {
      state = const FortuneListState(isLoading: false);
      return;
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final offset = refresh ? 0 : state.readings.length;
      final readings = await _repository.getFortuneReadings(
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = FortuneListState(
          readings: readings,
          hasMore: readings.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          readings: [...state.readings, ...readings],
          hasMore: readings.length >= _pageSize,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addReading(FortuneReading reading) {
    state = state.copyWith(readings: [reading, ...state.readings]);
  }

  void removeReading(String id) {
    state = state.copyWith(
      readings: state.readings.where((r) => r.id != id).toList(),
    );
  }

  void clear() {
    state = const FortuneListState();
  }
}

/// Fortune list provider
final fortuneListProvider =
    StateNotifierProvider<FortuneListNotifier, FortuneListState>((ref) {
  return FortuneListNotifier(ref.watch(fortuneRepositoryProvider));
});

/// Create fortune state
class CreateFortuneState {
  final bool isLoading;
  final FortuneReading? result;
  final String? error;
  final int? remainingToday;

  const CreateFortuneState({
    this.isLoading = false,
    this.result,
    this.error,
    this.remainingToday,
  });

  CreateFortuneState copyWith({
    bool? isLoading,
    FortuneReading? result,
    String? error,
    int? remainingToday,
  }) {
    return CreateFortuneState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
      remainingToday: remainingToday ?? this.remainingToday,
    );
  }
}

/// Create fortune notifier
class CreateFortuneNotifier extends StateNotifier<CreateFortuneState> {
  final FortuneRepository? _repository;
  final FortuneListNotifier _listNotifier;

  CreateFortuneNotifier(this._repository, this._listNotifier)
      : super(const CreateFortuneState());

  /// Create fortune using XFile (cross-platform compatible)
  Future<void> createFortune({
    required FortuneIntent intent,
    required XFile cupImage,
    XFile? saucerImage,
    String? customNote,
    String locale = 'tr',
  }) async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final reading = await _repository.createFortuneReading(
        intent: intent,
        cupImage: cupImage,
        saucerImage: saucerImage,
        customNote: customNote,
        locale: locale,
      );

      _listNotifier.addReading(reading);
      state = CreateFortuneState(result: reading);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const CreateFortuneState();
  }
}

/// Create fortune provider
final createFortuneProvider =
    StateNotifierProvider<CreateFortuneNotifier, CreateFortuneState>((ref) {
  return CreateFortuneNotifier(
    ref.watch(fortuneRepositoryProvider),
    ref.watch(fortuneListProvider.notifier),
  );
});

/// Single fortune reading provider
final fortuneReadingProvider =
    FutureProvider.family<FortuneReading?, String>((ref, id) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  if (repository == null) return null;
  return repository.getFortuneReading(id);
});

/// Fortune feedback provider
final fortuneFeedbackProvider =
    FutureProvider.family<FortuneFeedback?, String>((ref, readingId) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  if (repository == null) return null;
  return repository.getFeedback(readingId);
});

/// Pending feedback provider
final pendingFeedbackProvider =
    FutureProvider<List<FortuneReading>>((ref) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  if (repository == null) return [];
  return repository.getReadingsPendingFeedback();
});
